# Base image
FROM python:3.11.1-buster

# Define your working directory
WORKDIR /Test

# Install runpod
RUN pip install runpod

# Copy the start.sh script into the container and make it executable
COPY start.sh /run.sh
RUN chmod +x /run.sh

# Set the entrypoint to run the start.sh script
ENTRYPOINT ["/run.sh"]