#!/usr/bin/env bash

echo "Starting initialization..."

# Check if the RunPod volume exists and create a symlink
if [ -d "/runpod-volume" ]; then
    echo "Symlinking /runpod-volume to /workspace"
    rm -rf /workspace && \
    ln -s /runpod-volume /workspace
else
    echo "Error: /runpod-volume not found. Ensure the volume is mounted."
    exit 1
fi

# Change to the application directory
cd /app/fluxgym

# Run the Python application
echo "Starting the FluxGym Python application..."
exec python3 ./handler.py
