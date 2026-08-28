# Use a lightweight base image with Python from docker.io
FROM docker.io/python:3.14-slim

# picamera's setup.py aborts unless it detects a Raspberry Pi; READTHEDOCS is
# its documented bypass. Required to build this image anywhere but a Pi.
ENV READTHEDOCS=True
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# Install system dependencies, including libusb for PyUSB
RUN apt-get update && \
    apt-get install -y \
        wget \
        gnupg2 \
        curl \
        apt-transport-https \
        ca-certificates \
        libusb-1.0-0-dev \
        btop \
        htop \
        net-tools \
        git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Selects the dependency set, and so which image variant this is:
#   requirements.txt      -> full image (adds OpenCV + numpy for IP cameras)
#   requirements_lite.txt -> lite image (pure-Python deps only)
ARG REQUIREMENTS=requirements.txt

# Copy the main Python script, config file, and dependencies list
COPY noisebuster.py .
COPY config.json .
COPY ${REQUIREMENTS} ./requirements.txt

# Upgrade pip (conseillé)
RUN pip install --upgrade pip

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Create a directory for storing captured images (if needed)
RUN mkdir -p /images

# Set the command to start the application
CMD ["python", "noisebuster.py"]
