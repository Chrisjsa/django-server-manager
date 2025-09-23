#!/bin/bash

# Base project directory
PROJECT_DIR="/usr/local/mercurio-api"

# Set directories for logs, reports, and sessions
LOG_DIR="$PROJECT_DIR/log"
REPORTS_DIR="$PROJECT_DIR/reports"
SESSIONS_DIR="$PROJECT_DIR/sessions"
VENV_DIR="$PROJECT_DIR/venv"
APP_DIR="$PROJECT_DIR/app"

# SSL Certificates
SSL_CERT="/home/user/crm-pems/ssl-certificate.pem"
SSL_KEY="/home/user/crm-pems/ssl-key.pem"

# Path to the file containing container IDs and instance names
CONTAINER_FILE="container_ids"

# Log function for user-friendly output
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

# Function to check SSL certificate and key
check_ssl_files() {
    if [ ! -f "$SSL_CERT" ] || [ ! -f "$SSL_KEY" ]; then
        log "✖ Error: SSL certificate or key is missing. Both are required."
        exit 1
    else
        log "✔ SSL certificate and key found."
    fi
}

# Function to create the container IDs file if it does not exist
create_container_file() {
    if [ ! -f "$CONTAINER_FILE" ]; then
        log "* Container IDs file does not exist. Creating one."
        touch "$CONTAINER_FILE"
    fi
}

# Function to check if the container IDs file is empty
check_container_file_empty() {
    if [ ! -s "$CONTAINER_FILE" ]; then
        log "* Container IDs file is empty. Please provide the container IDs and instance names."
        while true; do
            echo "  Enter a container ID followed by its instance name (e.g., '7bfcfb758320 mariadb-instance'). Type 'done' when finished:"
            read -r input
            if [[ "$input" == "done" ]]; then
                break
            fi
            if [ -n "$input" ]; then
                echo "$input" >> "$CONTAINER_FILE"
            else
                log "  ✖ Input cannot be empty. Please enter a valid container ID and instance name."
            fi
        done
    fi
}

# Function to check and restart stopped containers
check_and_restart_containers() {
    create_container_file  # Create the container IDs file if it doesn't exist
    check_container_file_empty  # Check if the container IDs file is empty

    while read -r line; do
        container_id=$(echo "$line" | awk '{print $1}')
        instance_name=$(echo "$line" | cut -d' ' -f2-)
        log "* Checking container ID: $container_id"

        if [ "$(docker ps -aq -f id="$container_id")" ]; then
            if [ "$(docker inspect -f '{{.State.Status}}' "$container_id")" == "exited" ]; then
                log "  ➜ Container $container_id [$instance_name] is stopped. Restarting..."
                if docker start "$container_id"; then
                    log "  ✔ Container $container_id [$instance_name] has been restarted successfully."
                else
                    log "  ✖ Failed to restart container $container_id [$instance_name]."
                fi
            else
                log "  ✔ Container $container_id [$instance_name] is currently running."
            fi
        else
            log "  ✖ Container $container_id [$instance_name] does not exist. Skipping."
        fi
    done < "$CONTAINER_FILE"
}

# Function to create virtual environment if it does not exist
create_venv() {
    if [ ! -d "$VENV_DIR" ]; then
        log "Virtual environment not found. Creating one."
        python3 -m venv "$VENV_DIR"
        log "✔ Virtual environment created at $VENV_DIR."
    else
        log "✔ Virtual environment already exists."
    fi
}

# Function to activate the virtual environment
activate_venv() {
    source "$VENV_DIR/bin/activate"
    log "✔ Activated virtual environment."
}

# Function to check for running processes on the specified port
check_and_kill_port() {
    if lsof -i:$PORT; then
        log "✖ Port $PORT is currently occupied. Attempting to kill the existing process."
        lsof -ti:$PORT | xargs kill -9
        log "✔ Existing process on port $PORT has been killed."
    fi
}

# Function to display the menu and execute commands
display_menu() {
    PS3='Please enter your choice: '
    options=("Check Docker Containers" "Install Requirements" "Sync Roles" "Run Project" "Exit")

    while true; do
        select opt in "${options[@]}"; do
            case $opt in
                "Check Docker Containers")
                    echo -e "\n"
                    log "******* Checking containers listed in $CONTAINER_FILE..."
                    check_and_restart_containers
                    log "******* Container check completed."
                    break # Exit from select loop
                    ;;
                "Install Requirements")
                    echo -e "\n"
                    log "Installing requirements from app/requirements.txt..."
                    if pip install -r "$APP_DIR/requirements.txt"; then
                        log "✔ Requirements installed successfully."
                    else
                        log "✖ Failed to install requirements."
                    fi
                    break # Exit from select loop
                    ;;
                "Sync Roles")
                    echo -e "\n"
                    log "Syncing roles..."
                    if python3 "$APP_DIR/shipping_control_api_proj/manage.pyc" syncroles; then
                        log "✔ Roles synced successfully."
                    else
                        log "✖ Failed to sync roles."
                    fi
                    break # Exit from select loop
                    ;;
                "Run Project")
                    echo -e "\n"
                    log "Starting the Django project with SSL..."
                    check_and_kill_port # Check and kill process if port is occupied
                    python3 "$APP_DIR/shipping_control_api_proj/manage.pyc" runsslserver 0.0.0.0:13001 --certificate "$SSL_CERT" --key "$SSL_KEY" &
                    log "✔ Django project is running."
                    log "You can stop the server with CONTROL-C."
                    break # Exit from select loop
                    ;;
                "Exit")
                    echo -e "\n"
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

# Main script flow
log "Starting deployment and Docker management script..."

# Step 1: Check and create required directories
check_and_create_dirs

# Step 2: Check for SSL certificates
check_ssl_files

# Step 3: Create the virtual environment
create_venv

# Step 4: Activate the virtual environment
activate_venv

# Step 5: Display the menu for executing commands
display_menu

log "Deployment and Docker management script completed."
