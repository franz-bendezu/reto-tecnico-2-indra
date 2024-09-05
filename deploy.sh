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

# Kubernetes namespace creation (if needed)
kubectl get namespace $NAMESPACE > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Creating namespace: $NAMESPACE"
  kubectl create namespace $NAMESPACE
fi

# Deploy frontend resources
echo "Deploying frontend to Kubernetes..."
kubectl apply -f $K8S_DIR/frontend-deployment.yaml -n $NAMESPACE
kubectl apply -f $K8S_DIR/frontend-service.yaml -n $NAMESPACE

# Deploy backend API resources
echo "Deploying backend API to Kubernetes..."
kubectl apply -f $K8S_DIR/backend-deployment.yaml -n $NAMESPACE
kubectl apply -f $K8S_DIR/backend-service.yaml -n $NAMESPACE

# Check the status of the deployments and services
echo "Checking the status of the frontend and backend pods..."
kubectl get pods -n $NAMESPACE

echo "Checking the services..."
kubectl get svc -n $NAMESPACE

# Get NodePort of the frontend service
FRONTEND_NODEPORT=$(kubectl get svc frontend-service -n $NAMESPACE -o=jsonpath='{.spec.ports[0].nodePort}')
echo "Frontend service is exposed on NodePort: $FRONTEND_NODEPORT"

echo "Deployment completed."
