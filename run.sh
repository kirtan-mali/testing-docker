#!/bin/bash

# Enable error handling and command printing
set -ex

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Start initialization
log_message "Starting initialization..."
log_message "Current user and permissions:"
id
ls -l $(which bash)

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
log_message "Env directory permissions:"
ls -la env/
ls -la env/bin/

# Fix permissions if needed
log_message "Fixing permissions..."
chmod -R +x env/bin/
chmod +x env/bin/activate

# Check for required files/directories
if [ ! -f "handler.py" ]; then
    log_message "ERROR: handler.py not found in $(pwd)"
    exit 1
fi

if [ ! -d "env" ]; then
    log_message "ERROR: env directory not found in $(pwd)"
    exit 1
fi

# Try activating with bash explicitly
log_message "Activating virtual environment..."
if ! bash -c "source env/bin/activate"; then
    log_message "ERROR: Failed to activate environment with bash"
    log_message "Trying alternative activation method..."
    
    # Alternative activation method
    export VIRTUAL_ENV="$(pwd)/env"
    export PATH="$VIRTUAL_ENV/bin:$PATH"
    unset PYTHON_HOME
    
    # Verify activation
    if [[ "$PATH" != *"/env/bin"* ]]; then
        log_message "ERROR: Failed to activate environment using PATH method"
        exit 1
    fi
fi

# Verify Python environment
log_message "Python version and location:"
which python3
python3 --version

# Change to sd-scripts directory and install its requirements
# log_message "Installing sd-scripts requirements..."
# if [ -d "sd-scripts" ]; then
#     cd sd-scripts || {
#         log_message "ERROR: Could not change to sd-scripts directory"
#         exit 1
#     }
    
#     log_message "Current directory: $(pwd)"
    
#     if [ -f "requirements.txt" ]; then
#         log_message "Installing sd-scripts requirements..."
#         pip3 install --no-cache-dir -r requirements.txt || {
#             log_message "ERROR: Failed to install sd-scripts requirements"
#             exit 1
#         }
#     else
#         log_message "ERROR: requirements.txt not found in sd-scripts directory"
#         exit 1
#     fi
    
#     # Return to fluxgym directory
#     cd .. || {
#         log_message "ERROR: Could not return to fluxgym directory"
#         exit 1
#     }
# else
#     log_message "ERROR: sd-scripts directory not found"
#     exit 1
# fi
# 
# log_message "Installing fluxgym requirements..."
# if [ -f "requirements.txt" ]; then
#         log_message "Installing fluxgym requirements..."
#         pip3 install --no-cache-dir -r requirements.txt || {
#             log_message "ERROR: Failed to install fluxgym requirements"
#             exit 1
#         }
#     else
#         log_message "ERROR: requirements.txt not found in fluxgym directory"
#         exit 1
#     fi

# Run the handler.py
# pip3 install runpod
# pip3 install --force-reinstall -v "triton==3.1.0"
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
