#!/bin/bash
set -e

# 1. Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "ERROR: 'docker' command not found."
    echo "------------------------------------------------"
    echo "FIX: 1. Open Docker Desktop on Windows."
    echo "     2. Go to Settings > Resources > WSL Integration."
    echo "     3. Enable integration for your Ubuntu distro."
    echo "     4. Restart your terminal."
    exit 1
fi

# 2. Configuration (Updated with your username)
DOCKER_USER="darkhant"
IMAGE_NAME="tole-payment-app"
IMAGE_TAG="1.0"
FULL_IMAGE_NAME="$DOCKER_USER/$IMAGE_NAME:$IMAGE_TAG"

echo "--- 1. BUILDING IMAGE: $FULL_IMAGE_NAME ---"
docker build -t $FULL_IMAGE_NAME .

echo "--- 2. LOGGING IN ---"
echo "Please enter your Docker Hub password if prompted:"
docker login -u $DOCKER_USER

echo "--- 3. PUSHING TO DOCKER HUB ---"
docker push $FULL_IMAGE_NAME

echo "--- SUCCESS ---"
echo "Image published at: https://hub.docker.com/r/$DOCKER_USER/$IMAGE_NAME"
