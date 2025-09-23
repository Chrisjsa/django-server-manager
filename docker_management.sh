#!/bin/bash

# Load configuration variables
source ./config.sh

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
