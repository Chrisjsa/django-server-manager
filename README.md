
# Django-Server-Manager

**Django-Server-Manager** is a powerful toolset designed for managing Django projects and Docker containers efficiently. This project automates the deployment process, monitors server status, and manages backups, providing a reliable solution for developers.

## Features

- **Docker Container Management**: Check and restart Docker containers to ensure application availability.
- **Dependency Management**: Install required Python packages defined in `requirements.txt`.
- **Role Synchronization**: Sync user roles and permissions within Django projects.
- **Project Execution**: Start the Django application with SSL for secure communication.
- **Backup Functionality**: Backup existing files and restore from compiled project versions.

## Installation

1. **Clone the Repository**: 
   Clone the repository to your local machine.
   ```bash
   git clone <repository-url>
   cd <repository-folder>
   ```

2. **Make Scripts Executable**: 
   Use the following command to make all scripts executable:
   ```bash
   chmod +x scripts/*.sh
   ```

3. **Install Required Dependencies**: 
   Ensure you have Python and Docker installed on your machine.

## Configuration

### The Importance of `config.sh`

The `config.sh` file is crucial for defining all necessary configuration variables used throughout the other scripts. This centralized approach allows for easy management and modification of paths without having to dive into individual scripts. The variables defined in `config.sh` include:

- **PROJECT_NAME**: The name of the project, allowing for dynamic referencing across scripts.
- **COMPILE_DIR**: The directory where compiled ZIP files are located.
- **TEMP_DIR**: The temporary directory used during backup and unzip operations.
- **DEST_DIR**: The destination directory where files will be moved.
- **SSL_CERT**: Path to the SSL certificate file for secure connections.
- **SSL_KEY**: Path to the SSL key file for secure connections.
- **CONTAINER_FILE**: File that stores container IDs and instance names for Docker management.

### Example of `config.sh`

```bash
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
```

## Menu Options 

When you run `main_management.sh`, you will see the following menu:

```
Select an option:
1. Check Docker Containers
2. Install Requirements
3. Sync Roles
4. Run Project
5. Backup and Unzip
6. Exit
```

### Menu Options Explained

1. **Check Docker Containers**: 
   This option checks the status of specified Docker containers and restarts them if they are found to be stopped.

2. **Install Requirements**: 
   This option installs the necessary Python packages defined in the `requirements.txt` file.

3. **Sync Roles**: 
   This option runs Django management commands to synchronize user roles and permissions.

4. **Backup and Unzip**: 
   This option backs up existing files and unzips the latest compiled project version.

5. **Run Project**: 
   This option starts the Django server with SSL enabled to ensure secure communication.

6. **Exit**: 
   This option exits the script gracefully.

## Important Considerations

- **Variable Management**: 
  Ensure all paths in `config.sh` are correct to match your local setup. This includes paths for SSL certificates and the compiled directory.

- **Logging**: 
  The script logs success and errors to provide visibility into operations. Check corresponding log files if you encounter issues.

- **Cron Jobs**: 
  You can automate project monitoring by setting up cron jobs for relevant scripts, ensuring high availability.

## Usage

To run the main management script:
```bash
./scripts/main_management.sh
```

To monitor and restart the Django project:
- Use the script `check_and_run_project.sh` scheduled in a cron job.

```bash
* * * * * /path/to/check_and_run_project.sh
```

### Conclusion

Django-Server-Manager is designed to enhance your workflow when managing Django projects and Docker containers, ensuring seamless deployment, monitoring, and backup processes.

For contributions or issues, please open a pull request or submit an issue on the repository.

---

### License

This project is licensed under the MIT License.
```

### Summary
This README now comprehensively explains what the project does, how to install and configure it, and the purpose of each component, particularly emphasizing the role of the `config.sh` file. If you have any further changes or specific information you'd like to include, let me know!