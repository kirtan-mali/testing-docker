#!/usr/bin/env bash

# Enable error handling
set -e

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check directory/file existence
check_path() {
    if [ -e "$1" ]; then
        log_message "✓ Found: $1"
    else
        log_message "✗ Not found: $1"
        return 1
    fi
}

# Start initialization
log_message "Starting initialization..."

# List contents of root directory
log_message "Contents of root directory (/):"
ls -la / | sed 's/^/    /'

# Check and list runpod volume
if [ -d "/runpod-volume" ]; then
    log_message "Found RunPod volume. Contents of /runpod-volume:"
    ls -la /runpod-volume | sed 's/^/    /'
    
    log_message "Symlinking /runpod-volume to /workspace"
    rm -rf /workspace
    ln -s /runpod-volume /workspace
else
    log_message "ERROR: /runpod-volume not found. Ensure the volume is mounted."
    exit 1
fi

# List workspace contents after symlink
log_message "Contents of /workspace after symlink:"
ls -la /workspace | sed 's/^/    /'

# Check for fluxgym directory
if ! check_path "/workspace/fluxgym"; then
    log_message "ERROR: /workspace/fluxgym directory not found"
    exit 1
fi

# List contents of fluxgym directory
log_message "Contents of /workspace/fluxgym:"
ls -la /workspace/fluxgym | sed 's/^/    /'

# Check for handler.py
if ! check_path "/workspace/fluxgym/handler.py"; then
    log_message "ERROR: handler.py not found in /workspace/fluxgym/"
    exit 1
fi

# Check for virtual environment
if ! check_path "/app/env"; then
    log_message "ERROR: Virtual environment not found at /app/env"
    exit 1
fi

# Try to activate virtual environment
log_message "Activating virtual environment..."
if ! source /app/env/bin/activate; then
    log_message "ERROR: Failed to activate virtual environment"
    exit 1
fi

# Verify Python environment
log_message "Python version and location:"
which python3
python3 --version

# List installed Python packages
log_message "Installed Python packages:"
pip list | sed 's/^/    /'

# Run the Python application
log_message "Starting the FluxGym Python application..."
if python3 -u /workspace/fluxgym/handler.py; then
    log_message "Application exited successfully"
else
    exit_code=$?
    log_message "ERROR: Application exited with code ${exit_code}"
    exit ${exit_code}
fi