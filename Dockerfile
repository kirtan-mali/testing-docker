FROM nvidia/cuda:12.2.2-base-ubuntu22.04

# Install system packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo \
    python3 \
    python3-pip \
    python3-venv \
    git \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip3 install --upgrade pip

# Install PyTorch and other Python dependencies
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Copy the content of the repo to the container
COPY . /app

# Set the working directory
WORKDIR /app

# Ensure run.sh has execution permissions
RUN chmod +x run.sh

# Set the entrypoint to run.sh
ENTRYPOINT ["/app/run.sh"]