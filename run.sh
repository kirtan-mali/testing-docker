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

# Check for existence of virtual environment
if [ -d "env" ]; then
    log_message "Found virtual environment. Checking permissions:"
    ls -la env/
    ls -la env/bin/

    # Fix permissions if needed
    log_message "Fixing permissions..."
    chmod -R +x env/bin/
    chmod +x env/bin/activate

    # Activate virtual environment
    log_message "Activating virtual environment..."
    source env/bin/activate || {
        log_message "Failed to activate with source, trying alternative method"
        export VIRTUAL_ENV="$(pwd)/env"
        export PATH="$VIRTUAL_ENV/bin:$PATH"
        unset PYTHON_HOME
    }
else
    log_message "Creating new virtual environment..."
    python3 -m venv env
    chmod -R +x env/bin/
    source env/bin/activate || {
        log_message "Failed to activate with source, trying alternative method"
        export VIRTUAL_ENV="$(pwd)/env"
        export PATH="$VIRTUAL_ENV/bin:$PATH"
        unset PYTHON_HOME
    }
fi

# Verify Python environment
log_message "Python version and location:"
which python3
python3 --version

# Install triton and bitsandbytes explicitly
log_message "Installing critical dependencies..."
pip install --no-cache-dir torch==2.1.2 torchvision==0.16.2 --index-url https://download.pytorch.org/whl/cu121
pip install --no-cache-dir triton==2.1.0
pip install --no-cache-dir bitsandbytes==0.41.1
pip install --no-cache-dir diffusers==0.25.1 transformers==4.35.2 accelerate==0.25.0 safetensors==0.4.1

# Check for sd-scripts and install requirements
if [ -d "sd-scripts" ]; then
    log_message "Found sd-scripts directory. Installing requirements..."
    cd sd-scripts || {
        log_message "ERROR: Could not change to sd-scripts directory"
        exit 1
    }
    
    if [ -f "requirements.txt" ]; then
        log_message "Installing sd-scripts requirements..."
        pip install --no-cache-dir -r requirements.txt || {
            log_message "WARNING: Some sd-scripts requirements failed to install. Continuing anyway."
        }
    else
        log_message "WARNING: requirements.txt not found in sd-scripts directory"
    fi
    
    # Return to fluxgym directory
    cd .. || {
        log_message "ERROR: Could not return to fluxgym directory"
        exit 1
    }
else
    log_message "ERROR: sd-scripts directory not found. Attempting to clone..."
    git clone https://github.com/kohya-ss/sd-scripts.git
    cd sd-scripts || {
        log_message "ERROR: Could not change to sd-scripts directory after cloning"
        exit 1
    }
    
    if [ -f "requirements.txt" ]; then
        log_message "Installing sd-scripts requirements..."
        pip install --no-cache-dir -r requirements.txt || {
            log_message "WARNING: Some sd-scripts requirements failed to install. Continuing anyway."
        }
    fi
    
    cd .. || {
        log_message "ERROR: Could not return to fluxgym directory"
        exit 1
    }
fi

# Install fluxgym requirements
log_message "Installing fluxgym requirements..."
if [ -f "requirements.txt" ]; then
    pip install --no-cache-dir -r requirements.txt || {
        log_message "WARNING: Some fluxgym requirements failed to install. Continuing anyway."
    }
else
    log_message "WARNING: requirements.txt not found in fluxgym directory"
fi

# Double-check triton installation
log_message "Verifying triton installation..."
python3 -c "import triton; print(f'Triton version: {triton.__version__}')"
python3 -c "import triton.ops; print('Triton ops module found')" || {
    log_message "ERROR: triton.ops module not found. Attempting to fix..."
    pip uninstall -y triton
    pip install --no-cache-dir triton==2.1.0
}

# Add Python path for sd-scripts
log_message "Adding sd-scripts to Python path..."
export PYTHONPATH="$PYTHONPATH:/workspace/fluxgym/sd-scripts"

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