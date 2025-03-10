# Dockerfile
FROM nvidia/cuda:12.2.2-base-ubuntu22.04

# Install system packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    git \
    build-essential \
    gcc \
    g++ \
    cuda-toolkit-12-2 \
    libcudnn8 \
    libjpeg-dev \
    libpng-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip3 install --upgrade pip

# Install PyTorch and other Python dependencies
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118


COPY run.sh /run.sh
RUN chmod +x /run.sh

# Set the entrypoint
ENTRYPOINT ["/bin/bash", "/run.sh"]