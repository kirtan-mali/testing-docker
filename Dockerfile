# Dockerfile
FROM nvidia/cuda:12.2.2-devel-ubuntu22.04

# Set ENV variables for better installation
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

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
    wget \
    curl \
    ninja-build \
    libjpeg-dev \
    libpng-dev \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Upgrade pip
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel

# Install PyTorch and related libraries with specific versions 
# (using CUDA 12.1 which is compatible with CUDA 12.2)
RUN pip3 install --no-cache-dir torch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 --index-url https://download.pytorch.org/whl/cu121

# Install triton with specific version that has the 'ops' module
RUN pip3 install --no-cache-dir triton==2.1.0

# Install bitsandbytes with compatibility for CUDA
RUN pip3 install --no-cache-dir bitsandbytes==0.41.1

RUN pip3 install --no-cache-dir diffusers==0.25.1 transformers==4.35.2 accelerate==0.25.0 safetensors==0.4.1 huggingface-hub>=0.20.2 runpod pyyaml pillow python-slugify toml requests xformers

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Set up working directory
WORKDIR /workspace

# Set the entrypoint
ENTRYPOINT ["/bin/bash", "/run.sh"]