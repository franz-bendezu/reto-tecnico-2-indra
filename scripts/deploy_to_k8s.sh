#!/bin/bash

# Set environment variables
NAMESPACE="app"  # Optional, you can deploy in the default namespace
K8S_DIR="./k8s"  # Directory where the k8s manifests are stored

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

echo "Deployment completed."