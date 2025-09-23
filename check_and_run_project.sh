#!/bin/bash

# Load configuration variables
source ./config.sh

# Log file path for the cron task
LOG_FILE="${LOG_DIR}/crontask.log"

# Function for logging messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to check if the Django project is running
is_project_running() {
    # Check if the port is being used (adjust as necessary)
    if lsof -i:$PORT > /dev/null; then
        log "✔ Django project is running."
        return 0  # Project is running
    else
        log "✖ Django project is not running."
        return 1  # Project is not running
    fi
}

# Restart the project
restart_project() {
    log "Starting the Django project..."

    # Call main_management.sh and provide option to run project
    ./scripts/main_management.sh << EOF
4
EOF
}

# Main logic
if ! is_project_running; then
    restart_project
fi