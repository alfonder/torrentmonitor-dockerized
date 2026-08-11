<?php
// -----------------------------
// DB (sqlite) migration utility
// -----------------------------

$version_min = '2.0.1';

if (php_sapi_name() !== 'cli') {
    die("This script must be run from the command line.\n");
}

$dir = dirname(__FILE__).'/';
$rootdir = dirname(__FILE__).'/../';

require_once $rootdir . 'config.php';

// Read system version from version.txt
$versionData = json_decode(file_get_contents($rootdir . 'version.txt'));
$systemVersion = $versionData->system;

// Step 1: Check db.type
$dbType = Config::read('db.type');
if ($dbType !== 'sqlite') {
    echo "Migration not supported\n";
    exit(1);
}

// Step 1: Check if 'dbVersion' already exists in settings
$dbFile = Config::read('db.basename');
try {
    $pdo = new PDO('sqlite:' . $dbFile, null, null, [PDO::ATTR_PERSISTENT => false]);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo "Cannot open database: " . $e->getMessage() . "\n";
    exit(1);
}

$stmt = $pdo->query("SELECT COUNT(*) FROM settings WHERE key = 'dbVersion'");
if ($stmt->fetchColumn() > 0) {
    echo "Migration already done\n";
    exit(0);
}

// Step 2: Backup the sqlite file
$backupFile = $dbFile . '.' . $systemVersion;
if (!copy($dbFile, $backupFile)) {
    echo "Failed to create backup: $backupFile\n";
    exit(1);
}
echo "DB backup created: $backupFile\n";

// Step 3: Load cond.xml and update.xml
$condXmlPath = $dir . 'cond.xml';
$updateXmlPath = $dir . 'update.xml';

$cond_xml = @simplexml_load_file($condXmlPath);
if (!$cond_xml) {
    echo "Failed to load cond.xml\n";
    exit(1);
}

$xml_page = @simplexml_load_file($updateXmlPath);
if (!$xml_page) {
    echo "Failed to load update.xml\n";
    exit(1);
}

// Collect indexes in reverse order (oldest first), starting from version_min
$startIdx = null;
$updates = $cond_xml->update;
$count = count($updates);
for ($i = $count - 1; $i >= 0; $i--) {
    if (strval($updates[$i]->version) === $version_min) {
        $startIdx = $i;
        break;
    }
}
if ($startIdx === null) {
    echo "version_min '$version_min' not found in cond.xml\n";
    exit(1);
}

// Helper: run a single SELECT check query, return true if result is 'true'
function checkQuery(PDO $pdo, string $query): bool
{
    try {
        $stmt = $pdo->query($query);
        $row = $stmt->fetch(PDO::FETCH_NUM);
        return isset($row[0]) && trim($row[0]) === 'true';
    } catch (PDOException $e) {
        echo "  Check query error: " . $e->getMessage() . "\n";
        return false;
    }
}

// Helper: run a migration (non-SELECT) query
function migrateQuery(PDO $pdo, string $query): bool
{
    try {
        $pdo->exec($query);
        return true;
    } catch (PDOException $e) {
        echo "  Migration query error: " . $e->getMessage() . "\n";
        echo "  Query was: " . substr($query, 0, 120) . "\n";
        return false;
    }
}

// Steps 4-6: Iterate from version_min upward (indexes match between both XMLs)
$migrationsPerformed = 0;
for ($i = $startIdx; $i >= 0; $i--) {
    $condEntry = $cond_xml->update[$i];
    $migrateEntry = $xml_page->update[$i];
    $version = strval($condEntry->version);

    // Step 5: Check dbType-specific queries (sqlite section in cond.xml)
    $dbTypeQueries = $condEntry->$dbType;
    if (!empty($dbTypeQueries->query)) {
        $allTrue = true;
        foreach ($dbTypeQueries->query as $query) {
            if (!checkQuery($pdo, strval($query))) {
                $allTrue = false;
                break;
            }
        }
        if ($allTrue) {
            echo "Migrating DB to version $version (sqlite)\n";
            foreach ($migrateEntry->$dbType->query ?? [] as $query) {
                if (migrateQuery($pdo, strval($query))) {
                    $migrationsPerformed++;
                }
            }
        }
    }

    // Step 6: Check common (queryes) queries
    if (!empty($condEntry->queryes->query)) {
        $allTrue = true;
        foreach ($condEntry->queryes->query as $query) {
            if (!checkQuery($pdo, strval($query))) {
                $allTrue = false;
                break;
            }
        }
        if ($allTrue) {
            echo "Migrating DB to version $version\n";
            foreach ($migrateEntry->queryes->query ?? [] as $query) {
                if (migrateQuery($pdo, strval($query))) {
                    $migrationsPerformed++;
                }
            }
        }
    }
}

// Step 7: Insert dbVersion record
try {
    $pdo->exec("INSERT INTO settings VALUES (41, 'dbVersion', '$systemVersion')");
} catch (PDOException $e) {
    echo "Failed to insert dbVersion: " . $e->getMessage() . "\n";
    exit(1);
}

// Step 8
echo ($migrationsPerformed > 0 ? "Migration complete" : "Migration not needed") . "\n";
