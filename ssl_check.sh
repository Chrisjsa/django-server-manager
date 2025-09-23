#!/bin/bash

# Load configuration variables
source ./config.sh

# Function to check SSL certificate and key
check_ssl_files() {
    if [ ! -f "$SSL_CERT" ] || [ ! -f "$SSL_KEY" ]; then
        log "✖ Error: SSL certificate or key is missing. Both are required."
        exit 1
    else
        log "✔ SSL certificate and key found."
    fi
}
