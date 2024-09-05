#!/bin/bash

# Set environment variables
NAMESPACE="app"  # Optional, you can deploy in the default namespace

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

echo "Service check completed."