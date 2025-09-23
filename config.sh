#!/bin/bash

# Project-specific variables
PROJECT_NAME="project"  # Adjust as needed
PORT=13001               # Adjust as needed
SYSTEM_USER="user"

# Base project directory
PROJECT_DIR="/usr/local/${PROJECT_NAME}-api"

# Set directories for logs, reports, and sessions
LOG_DIR="$PROJECT_DIR/log"
REPORTS_DIR="$PROJECT_DIR/reports"
SESSIONS_DIR="$PROJECT_DIR/sessions"
VENV_DIR="$PROJECT_DIR/venv"
APP_DIR="$PROJECT_DIR/app"

# Backup paths
COMPILE_DIR="/home/${SYSTEM_USER}/compiled"
TEMP_DIR="${PROJECT_NAME}_temp"
DEST_DIR=APP_DIR  # Default backup destination directory

# SSL Certificates
SSL_DIR_NAME="pems"
SSL_CERT="/home/${SYSTEM_USER}/${SSL_DIR_NAME}/ssl-certificate.pem"
SSL_KEY="/home/${SYSTEM_USER}/${SSL_DIR_NAME}/ssl-key.pem"

# Path to the file containing container IDs and instance names
CONTAINER_FILE="container_ids"
