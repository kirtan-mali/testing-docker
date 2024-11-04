# Base image
FROM python:3.11.1-buster

# Create a symlink for the RunPod network volume
RUN ln -s /runpod-volume /workspace

# Define your working directory
WORKDIR /Test

# Install runpod
RUN pip install runpod

# Copy your Python file into the container
ADD /Test/whatever.py .

# Set the command to run your script when the container starts
CMD [ "python", "-u", "/Test/whatever.py" ]