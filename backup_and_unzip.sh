#!/bin/bash

# Load configuration variables
source ./config.sh

# Function for logging messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Get custom compile directory from user
read -p "Enter the path for the compiled ZIP files (default: $COMPILE_DIR): " user_compile_dir
COMPILE_DIR=${user_compile_dir:-$COMPILE_DIR}

# Validate that at least one ZIP file exists containing the project name
log "Checking for ZIP files in $COMPILE_DIR containing '$PROJECT_NAME'..."
zips=($(ls "$COMPILE_DIR"/*"$PROJECT_NAME"*.zip 2>/dev/null))

if [ ${#zips[@]} -eq 0 ]; then
    log "✖ No ZIP files found containing '$PROJECT_NAME' in $COMPILE_DIR."
    exit 1
fi

# If multiple ZIP files exist, find the most recent one
latest_zip=$(printf "%s\n" "${zips[@]}" | xargs stat --format='%Y %n' | sort -n | tail -1 | cut -d' ' -f2-)

log "✔ Most recent ZIP file found: $latest_zip"

# Unzip the latest ZIP file into the temporary directory
log "Unzipping $latest_zip..."
unzip -o "$latest_zip" || { log "✖ Failed to unzip $latest_zip"; exit 1; }

# Remove the ZIP file after extraction
log "Removing ZIP file: $latest_zip"
rm "$latest_zip"

# Get custom destination directory from user
read -p "Enter the destination directory (default: $DEST_DIR): " user_dest_dir
DEST_DIR=${user_dest_dir:-$DEST_DIR}

# Create a backup of the destination directory
backup_prefix="backup-"
max_backup_num=0
backup_dir=""

# Find existing backup directories and determine the new backup directory name
for dir in "$DEST_DIR"/${backup_prefix}*; do
    if [[ -d "$dir" ]]; then
        num=${dir##*-}  # Get the number after 'backup-'
        if (( num > max_backup_num )); then
            max_backup_num=$num
        fi
    fi
done

# Determine the name for the new backup directory
backup_dir="${DEST_DIR}/${backup_prefix}$((max_backup_num + 1))"
log "Creating backup directory: $backup_dir"
mkdir -p "$backup_dir"

# Confirm backup directory location
log "Backing up existing files in $DEST_DIR to $backup_dir..."
rsync -av --exclude="${backup_prefix}*" "$DEST_DIR/" "$backup_dir/"
log "✔ Backup completed. Backed up files are located in: $backup_dir"

# Ask for user confirmation to proceed
read -p "Do you want to proceed with removing the original files in $DEST_DIR? (n to cancel): " proceed
if [[ "$proceed" == "n" ]]; then
    log "✖ Operation canceled by user."
    exit 0
fi

# Remove all files and directories in the destination directory except for backup directories
log "Removing old files and directories from $DEST_DIR, keeping backup directories..."
find "$DEST_DIR" -mindepth 1 ! -name "${backup_prefix}*" -exec rm -rf {} +

# Move the extracted files from TEMP_DIR to the destination directory
log "Moving extracted files from $TEMP_DIR to the destination directory: $DEST_DIR..."
mv "$TEMP_DIR/"* "$DEST_DIR/"
log "✔ Extracted files moved to $DEST_DIR."

# Clean up temporary directory
log "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"
log "✔ Temporary directory $TEMP_DIR removed."

# Cleanup old backups if more than 4 exist
backup_count=$(ls -1 "$DEST_DIR"/${backup_prefix}* 2>/dev/null | wc -l)
if [ "$backup_count" -gt 4 ]; then
    oldest_backup=$(ls -dt "$DEST_DIR"/${backup_prefix}* | tail -1)
    log "✖ More than 4 backup directories found. Removing oldest backup: $oldest_backup"
    rm -rf "$oldest_backup"
    log "✔ Old backup removed."
fi

log "Backup and unzip process completed successfully."
