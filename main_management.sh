#!/bin/bash

# Load configuration variables
source ./config.sh

# Import functions from other scripts
source ./directory_management.sh
source ./ssl_check.sh
source ./docker_management.sh
source ./venv_management.sh

# Main script flow
log "Starting deployment and Docker management script..."

# Check and create required directories
check_and_create_dirs

# Check for SSL certificates
check_ssl_files

# Create the virtual environment
create_venv

# Activate the virtual environment
activate_venv

# Function to check for running processes on the specified port
check_and_kill_port() {
    PORT=13001
    if lsof -i:$PORT; then
        log "✖ Port $PORT is currently occupied. Attempting to kill the existing process."
        lsof -ti:$PORT | xargs kill -9
        log "✔ Existing process on port $PORT has been killed."
    fi
}

# Display the menu for executing commands
display_menu() {
    PS3='Please enter your choice: '
    options=("Check Docker Containers" "Install Requirements" "Sync Roles" "Run Project" "Backup and Unzip" "Exit")

    while true; do
        select opt in "${options[@]}"; do
            case $opt in
                "Check Docker Containers")
                    log "******* Checking containers listed in $CONTAINER_FILE..."
                    check_and_restart_containers
                    log "******* Container check completed."
                    break
                    ;;
                "Install Requirements")
                    log "Installing requirements from app/requirements.txt..."
                    pip install -r "$APP_DIR/requirements.txt" && log "✔ Requirements installed successfully." || log "✖ Failed to install requirements."
                    break
                    ;;
                "Sync Roles")
                    log "Syncing roles..."
                    python3 "$APP_DIR/$DJANGO_SETTING_MODULE/manage.pyc" syncroles && log "✔ Roles synced successfully." || log "✖ Failed to sync roles."
                    break
                    ;;
                "Run Project")
                    log "Starting the Django project with SSL..."
                    check_and_kill_port
                    nohup python3 "$APP_DIR/$DJANGO_SETTING_MODULE/manage.pyc" runsslserver 0.0.0.0:13001 --certificate "$SSL_CERT" --key "$SSL_KEY" &
                    log "✔ Django project is running. You can stop the server with CONTROL-C."
                    break
                    ;;
                "Backup and Unzip")
                    log "Initiating Backup and Unzip process..."
                    # Call the backup and unzip script when the user chooses this option
                    ./backup_and_unzip.sh  # This will execute the backup and unzip script
                    break
                    ;;
                "Exit")
                    log "Exiting the script."
                    exit 0
                    ;;
                *)
                    log "✖ Invalid option. Please try again."
                    ;;
            esac
        done
        echo -e "\n"
    done
}

# Run the menu
display_menu

log "Deployment and Docker management script completed."