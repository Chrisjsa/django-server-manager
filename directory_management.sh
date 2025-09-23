#!/bin/bash

# Load configuration variables
source ./config.sh

# Function for logging messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to check and create directories with proper permissions
check_and_create_dirs() {
    for dir in "$LOG_DIR" "$REPORTS_DIR" "$SESSIONS_DIR"; do
        if [ ! -d "$dir" ]; then
            log "Directory $dir does not exist. Creating it now."
            mkdir -p "$dir"
            chown user:user "$dir"
            chmod 755 "$dir"
            log "✔ Directory $dir created with permissions set to 755."
        else
            log "✔ Directory $dir already exists."
        fi
    done
}
