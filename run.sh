#!/bin/bash

# Enable error handling and command printing
set -ex

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check command existence
check_command() {
    if ! command -v $1 &> /dev/null; then
        log_message "ERROR: $1 command not found"
        exit 1
    fi
}

# Check required commands
check_command python3
check_command pip3

# Start initialization
log_message "Starting initialization..."

# Check and list runpod volume
if [ -d "/runpod-volume" ]; then
    log_message "Found RunPod volume. Contents of /runpod-volume:"
    ls -la /runpod-volume
    
    log_message "Symlinking /runpod-volume to /workspace"
    rm -rf /workspace
    ln -s /runpod-volume /workspace
else
    log_message "ERROR: /runpod-volume not found. Ensure the volume is mounted."
    exit 1
fi

# Change to fluxgym directory
cd /workspace/fluxgym || {
    log_message "ERROR: Could not change to /workspace/fluxgym directory"
    exit 1
}

log_message "Current directory: $(pwd)"
log_message "Directory contents:"
ls -la

# Ensure handler.py exists
if [ ! -f "handler.py" ]; then
    log_message "ERROR: handler.py not found in $(pwd)"
    exit 1
fi

# Create and setup virtual environment
log_message "Setting up Python environment..."
export PYTHONPATH="${PYTHONPATH}:/workspace/fluxgym"
python3 -m venv env || {
    log_message "ERROR: Failed to create virtual environment"
    exit 1
}

# Activate virtual environment with full path
source "$(pwd)/env/bin/activate" || {
    log_message "ERROR: Failed to activate virtual environment"
    exit 1
}

# Verify Python environment
log_message "Python version and location:"
which python3
python3 --version
which pip3

# Install main requirements if present
if [ -f "requirements.txt" ]; then
    log_message "Installing main requirements from $(pwd)/requirements.txt"
    pip3 install --no-cache-dir -r requirements.txt || {
        log_message "ERROR: Failed to install main requirements"
        exit 1
    }
else
    log_message "WARNING: requirements.txt not found in $(pwd)"
fi

# Change to sd-scripts directory and install its requirements
log_message "Installing sd-scripts requirements..."
if [ -d "sd-scripts" ]; then
    cd sd-scripts || {
        log_message "ERROR: Could not change to sd-scripts directory"
        exit 1
    }
    
    log_message "Current directory: $(pwd)"
    log_message "sd-scripts directory contents:"
    ls -la
    
    if [ -f "requirements.txt" ]; then
        log_message "Installing sd-scripts requirements..."
        pip3 install --no-cache-dir -r requirements.txt || {
            log_message "ERROR: Failed to install sd-scripts requirements"
            exit 1
        }
    else
        log_message "ERROR: requirements.txt not found in sd-scripts directory"
        exit 1
    fi
    
    # Return to fluxgym directory
    cd .. || {
        log_message "ERROR: Could not return to fluxgym directory"
        exit 1
    }
else
    log_message "ERROR: sd-scripts directory not found"
    exit 1
fi

# List installed packages
log_message "All installed Python packages:"
pip3 list

# Print environment variables
log_message "Environment variables:"
env

# Run the handler.py
log_message "Starting handler.py..."
python3 -u handler.py

exit_code=$?
if [ $exit_code -ne 0 ]; then
    log_message "ERROR: handler.py exited with code ${exit_code}"
    if [ -f "error.log" ]; then
        log_message "Last few lines of error.log:"
        tail -n 20 error.log
    fi
    exit ${exit_code}
fi

log_message "Handler completed successfully"