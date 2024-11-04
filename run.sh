#!/usr/bin/env bash

echo "Worker Initiated"

# Check if /runpod-volume exists and create a symlink to /workspace
if [ -d "/runpod-volume" ]; then
    echo "Symlinking /runpod-volume to /workspace"
    rm -rf /workspace && \
    ln -s /runpod-volume /workspace
else
    echo "Error: /runpod-volume not found. Ensure the volume is mounted."
    exit 1
fi

echo "Starting RunPod Handler"
# Run your Python script from /Test or the appropriate path
python3 -u /runpod-volume/Test/whatever.py