
# Enable error handling
set -e

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Start initialization
log_message "Starting initialization..."

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

# Check fluxgym directory
if [ ! -d "/workspace/fluxgym" ]; then
    log_message "ERROR: /workspace/fluxgym directory not found"
    exit 1
fi

cd /workspace/fluxgym
log_message "Changed directory to /workspace/fluxgym"

# Check handler.py
if [ ! -f "handler.py" ]; then
    log_message "ERROR: handler.py not found"
    exit 1
fi

# Create and setup virtual environment
log_message "Setting up Python environment..."
if [ ! -d "env" ]; then
    log_message "Creating virtual environment..."
    python3 -m venv env
fi

# Activate virtual environment
log_message "Activating virtual environment..."
source env/bin/activate

# Install requirements if present
if [ -f "requirements.txt" ]; then
    log_message "Installing requirements from requirements.txt..."
    pip install -r requirements.txt
else
    log_message "WARNING: requirements.txt not found"
fi

# Verify Python environment
log_message "Python version and location:"
which python3
python3 --version

# List installed packages
log_message "Installed Python packages:"
pip list | sed 's/^/    /'

# Run the handler.py
log_message "Starting handler.py..."
python3 -u handler.py

exit_code=$?
if [ $exit_code -ne 0 ]; then
    log_message "ERROR: handler.py exited with code ${exit_code}"
    # Print the last few lines of any error logs if they exist
    if [ -f "error.log" ]; then
        log_message "Last few lines of error.log:"
        tail -n 20 error.log
    fi
    exit ${exit_code}
fi

log_message "Handler completed successfully"