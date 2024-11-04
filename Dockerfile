# Base image
FROM python:3.11.1-buster


# Define your working directory
WORKDIR /Test

# Install runpod
RUN pip install runpod

RUN ls

# Copy your Python file into the container
ADD /runpod-volume/Test/whatever.py .

# Set the command to run your script when the container starts
CMD [ "python", "-u", "/runpod-volume/Test/whatever.py" ]