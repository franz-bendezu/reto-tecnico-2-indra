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

# Get the IP address of the Kubernetes node
NODE_IP=$(kubectl get nodes -o=jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
echo "Kubernetes node IP: $NODE_IP"

# Use curl to check the frontend service
FRONTEND_URL="http://$NODE_IP:$FRONTEND_NODEPORT"
echo "Checking frontend service at $FRONTEND_URL..."
curl $FRONTEND_URL 

# Port-forward to the backend service
BACKEND_LOCAL_PORT=8081
BACKEND_SERVICE_PORT=$(kubectl get svc backend-service -n $NAMESPACE -o=jsonpath='{.spec.ports[0].port}')
echo "Port-forwarding local port $BACKEND_LOCAL_PORT to backend service port $BACKEND_SERVICE_PORT..."
kubectl port-forward svc/backend-service $BACKEND_LOCAL_PORT:$BACKEND_SERVICE_PORT -n $NAMESPACE &
PORT_FORWARD_PID=$!
# Wait for port-forward to establish
sleep 5

# Use curl to check the backend service
BACKEND_URL="http://localhost:$BACKEND_LOCAL_PORT/products"
echo "Checking backend service at $BACKEND_URL..."
curl $BACKEND_URL

# Stop port-forwarding
echo "Stopping port-forwarding..."
kill $PORT_FORWARD_PID

echo "Deployment completed."