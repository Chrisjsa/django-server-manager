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
    local CURRENT_PORT="$1"

    if lsof -i:"$CURRENT_PORT" > /dev/null; then
        log "✖ Port $CURRENT_PORT is currently occupied. Attempting to kill the existing process."
        local PID=$(lsof -ti:"$CURRENT_PORT")
        if kill -9 $PID; then
            log "✔ Existing process on port $CURRENT_PORT has been killed."
        else
            log "✖ Failed to kill the process on port $CURRENT_PORT."
        fi
    else
        log "✔ Port $CURRENT_PORT is free."
    fi
}
# Display the menu for executing commands
display_menu() {
    PS3='Please enter your choice: '
    options=("Check Docker Containers" "Install Requirements" "Sync Roles" "Backup and Unzip" "Run Project" "Run Celery" "Run UI" "Exit")

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
                "Backup and Unzip")
                    log "Initiating Backup and Unzip process..."
                    # Call the backup and unzip script when the user chooses this option
                    ./backup_and_unzip.sh  # This will execute the backup and unzip script
                    break
                    ;;
                "Run Project")
                    log "Starting the Django project with SSL..."
                    check_and_kill_port "$PORT"
                    nohup python3 "$APP_DIR/$DJANGO_SETTING_MODULE/manage.pyc" runsslserver 0.0.0.0:$PORT --certificate "$SSL_CERT" --key "$SSL_KEY"  > "${LOG_DIR}/django_activity.log" 2>&1 &  # Run a leave to menu
                    log "✔ Django project is running. You can stop the server with CONTROL-C."
                    #cd $APP_DIR
                    #pwd
                    #nohup celery -A shipping_control_api_proj.celery_config worker --loglevel=info > "${LOG_DIR}/celery_worker.log" 2>&1 &
                    #log "✔ Celery Worker started."
                    #nohup celery -A shipping_control_api_proj.celery_config beat --loglevel=info > "${LOG_DIR}/celery_beat.log" 2>&1 &
                    #log "✔ Celery Beat started."
                    #break
                    ;;
                "Run Celery")
                    log "Checking for existing Celery processes..."
                    # Check for running Celery workers and beat
                    if ps aux | grep -v grep | grep 'celery'; then
                        log "Existing Celery processes found. Terminating them..."
                        pkill -f 'celery'  # This will kill all celery processes running
                    else
                        log "No existing Celery processes found."
                    fi
                    cd $APP_DIR
                    pwd
                    nohup celery -A shipping_control_api_proj.celery_config worker --loglevel=info > "${LOG_DIR}/celery_worker.log" 2>&1 &
                    log "✔ Celery Worker started."
                    nohup celery -A shipping_control_api_proj.celery_config beat --loglevel=info > "${LOG_DIR}/celery_beat.log" 2>&1 &
                    log "✔ Celery Beat started."
                    break
                    ;;
                "Run UI")
                    log "Starting the VUE project with SSL..."
                    check_and_kill_port "$UI_PORT"
                    cd $UI_DIR
                    nohup http-server -S -C "$SSL_CERT" -K "$SSL_KEY" -p 12001 --proxy http://localhost:$UI_PORT > "${LOG_DIR}/vue_activity.log" 2>&1 &
                    log "✔ VUE is running."
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