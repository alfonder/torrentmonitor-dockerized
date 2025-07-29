#!/bin/sh

# TorrentMonitor Dockerized Patch Script
# This script applies necessary patches to TorrentMonitor files for Docker integration

HTDOCS_DIR="${HTDOCS_DIR:-/data/htdocs}"

# Function to apply qBittorrent category patch
apply_qbittorrent_patch() {
    local qbittorrent_file="${HTDOCS_DIR}/class/qBittorrent.class.php"
    
    if [ ! -f "$qbittorrent_file" ]; then
        echo "ERROR: qBittorrent.class.php file not found at $qbittorrent_file"
        return 1
    fi
    
    # Check if the environment variable is set
    if [ -z "${QBITTORRENT_CATEGORY}" ]; then
        echo "QBITTORRENT_CATEGORY not set, skipping qBittorrent category patch"
        return 0
    fi
    
    # Check if patch is already applied
    if grep -q "'category'" "$qbittorrent_file"; then
        echo "qBittorrent category patch already applied"
        return 0
    fi
    
    # Apply the patch - add category parameter after root_folder line
    # Based on the patch file, we need to add it after the 'root_folder' => true, line
    # Extract the indentation from the root_folder line to match it exactly
    local indent=$(sed -n "/^[[:space:]]*'root_folder' => true,/s/\('root_folder'.*\)//p" "$qbittorrent_file")
    
    if sed -i "/^[[:space:]]*'root_folder' => true,/a\\
${indent}'category' => getenv('QBITTORRENT_CATEGORY') ?: ''," "$qbittorrent_file"; then
        echo "SUCCESS: Applied qBittorrent category patch"
        return 0
    else
        echo "ERROR: Failed to apply qBittorrent category patch"
        return 1
    fi
}

# Function to apply Update.class.php patch to call this script after updates
apply_update_patch() {
    local update_file="${HTDOCS_DIR}/class/Update.class.php"
    
    if [ ! -f "$update_file" ]; then
        echo "ERROR: Update.class.php not found at $update_file"
        return 1
    fi
    
    # Check if patch is already applied
    if grep -q "apply-patches.sh" "$update_file"; then
        echo "Update class patch already applied"
        return 0
    fi
    
    echo "Applying Update class patch..."
    
    # Find the end of the "if (Update::$isUpdated)" block and add our patch call there
    # We want to add our patch inside the isUpdated condition so it only runs after actual updates
    if sed -i "/if (Update::\\\$isUpdated)/,/^[[:space:]]*}[[:space:]]*$/s/^[[:space:]]*}[[:space:]]*$/                \/\/ Apply Docker patches after successful update\\
                if (file_exists('\/usr\/local\/bin\/apply-patches.sh')) {\\
                    shell_exec('\/usr\/local\/bin\/apply-patches.sh > \/dev\/null 2>\&1 \&');\\
                }\\
            }/g" "$update_file"; then
        echo "SUCCESS: Applied Update class patch"
        return 0
    else
        echo "ERROR: Failed to apply Update class patch"
        return 1
    fi
}

# Function to apply all patches
apply_all_patches() {
    echo "Starting patch application..."
    
    local success=0
    
    if apply_qbittorrent_patch; then
        success=$((success + 1))
    fi
    
    if apply_update_patch; then
        success=$((success + 1))
    fi
    
    if [ $success -eq 2 ]; then
        echo "All patches applied successfully"
        return 0
    else
        echo "Some patches failed to apply"
        return 1
    fi
}

# Main execution
case "${1:-apply}" in
    "apply")
        apply_all_patches
        ;;
    "qbittorrent")
        apply_qbittorrent_patch
        ;;
    "update")
        apply_update_patch
        ;;
    "check")
        # Check if patches are applied
        qb_file="$HTDOCS_DIR/class/qBittorrent.class.php"
        update_file="$HTDOCS_DIR/class/Update.class.php"
        
        qb_patched=0
        update_patched=0
        
        if [ -f "$qb_file" ] && grep -q "getenv('QBITTORRENT_CATEGORY')" "$qb_file"; then
            qb_patched=1
        fi
        
        if [ -f "$update_file" ] && grep -q "apply-patches.sh" "$update_file"; then
            update_patched=1
        fi
        
        echo "qBittorrent patch: $(if [ $qb_patched -eq 1 ]; then echo 'APPLIED'; else echo 'NOT APPLIED'; fi)"
        echo "Update patch: $(if [ $update_patched -eq 1 ]; then echo 'APPLIED'; else echo 'NOT APPLIED'; fi)"
        
        if [ $qb_patched -eq 1 ] && [ $update_patched -eq 1 ]; then
            exit 0
        else
            exit 1
        fi
        ;;
    *)
        echo "Usage: $0 [apply|qbittorrent|update|check]"
        echo "  apply       - Apply all patches (default)"
        echo "  qbittorrent - Apply only qBittorrent category patch"
        echo "  update      - Apply only Update class patch"
        echo "  check       - Check if patches are applied"
        exit 1
        ;;
esac
