#!/bin/bash

# Set environment variables
FRONTEND_IMAGE="frontend:latest"
BACKEND_IMAGE="backend:latest"
DOCKER_HUB_USERNAME="franzant"
NAMESPACE="app"  # Optional, you can deploy in the default namespace
K8S_DIR="./k8s"  # Directory where the k8s manifests are stored

# Build Docker images
echo "Building frontend Docker image..."
docker build -t $FRONTEND_IMAGE ./frontend

echo "Building backend Docker image..."
docker build -t $BACKEND_IMAGE ./backend

# Tag Docker images
dokcer tag $FRONTEND_IMAGE $DOCKER_HUB_USERNAME/$FRONTEND_IMAGE
dokcer tag $BACKEND_IMAGE $DOCKER_HUB_USERNAME/$BACKEND_IMAGE

# Push Docker images to Docker Hub
echo "Pushing frontend Docker image to Docker Hub..."
docker push $DOCKER_HUB_USERNAME/$FRONTEND_IMAGE
docker push $DOCKER_HUB_USERNAME/$BACKEND_IMAGE 