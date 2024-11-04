from python:3.11.1-buster

RUN ln -s /runpod-volume /workspace

# Include Python
from python:3.11.1-buster

# Define your working directory
WORKDIR /Test

# Install runpod
RUN pip install runpod

# Add your file
ADD whatever.py .

# Call your file when your container starts
CMD [ "python", "-u", "/whatever.py" ]