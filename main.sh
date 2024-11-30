#!/bin/bash

# Variables
ENV_FILE=".env"
COMMANDS=(
    "fan info"
    "fan p 0 max 60"
    "fan p 1 max 60"
    "fan p 6 max 60"
    "fan p 5 max 60"
    "fan p 4 max 60"
    "fan p 3 max 60"
    "fan p 2 max 60"
)

# Function to create a .env file if it doesn't exist
function create_env_file() {
    if [[ ! -f "$ENV_FILE" ]]; then
        echo "Creating $ENV_FILE..."
        cat << EOF > "$ENV_FILE"
# iLO Configuration
REMOTE_USER=Administrator
REMOTE_PASSWORD=your_password_here
REMOTE_HOST=10.201.0.14
EOF
        echo "$ENV_FILE created. Please update it with the correct values and rerun the script."
        exit 1
    fi
}

# Load the .env file
function load_env_file() {
    if [[ -f "$ENV_FILE" ]]; then
        source "$ENV_FILE"
    else
        echo "$ENV_FILE not found. Creating one..."
        create_env_file
    fi

    # Check if required variables are set
    if [[ -z "$REMOTE_USER" || -z "$REMOTE_PASSWORD" || -z "$REMOTE_HOST" ]]; then
        echo "Please ensure REMOTE_USER, REMOTE_PASSWORD, and REMOTE_HOST are set in $ENV_FILE."
        exit 1
    fi
}

# Function to execute commands via SSH
function execute_commands() {
    sshpass -p "$REMOTE_PASSWORD" ssh -o HostKeyAlgorithms=+ssh-rsa -o KexAlgorithms=diffie-hellman-group1-sha1 "${REMOTE_USER}@${REMOTE_HOST}" << EOF
$(for cmd in "${COMMANDS[@]}"; do
    echo "$cmd"
done)
EOF
}

# Ensure sshpass is installed
if ! command -v sshpass &>/dev/null; then
    echo "sshpass is not installed. Install it with: sudo apt install sshpass"
    exit 1
fi

# Load environment variables
load_env_file

# Run the commands on the remote machine
execute_commands
