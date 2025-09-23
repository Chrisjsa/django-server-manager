#!/bin/bash

# Load configuration variables
source ./config.sh

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
