#!/bin/bash

# Build and Deploy Script for Webhook CronJob

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
IMAGE_NAME="webhook-cronjob"
IMAGE_TAG="latest"
NAMESPACE="default"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--tag)
            IMAGE_TAG="$2"
            shift 2
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -t, --tag TAG        Docker image tag (default: latest)"
            echo "  -n, --namespace NS   Kubernetes namespace (default: default)"
            echo "  -h, --help           Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

echo -e "${GREEN}Building and deploying Webhook CronJob${NC}"
echo -e "${YELLOW}Image: $IMAGE_NAME:$IMAGE_TAG${NC}"
echo -e "${YELLOW}Namespace: $NAMESPACE${NC}"

# Step 1: Build Docker image
echo -e "\n${GREEN}Step 1: Building Docker image...${NC}"
docker build -t $IMAGE_NAME:$IMAGE_TAG .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Docker image built successfully${NC}"
else
    echo -e "${RED}✗ Failed to build Docker image${NC}"
    exit 1
fi

# Step 2: Load image into kind cluster (if using kind)
if kubectl config current-context | grep -q "kind"; then
    echo -e "\n${GREEN}Step 2: Loading image into kind cluster...${NC}"
    kind load docker-image $IMAGE_NAME:$IMAGE_TAG

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Image loaded into kind cluster${NC}"
    else
        echo -e "${RED}✗ Failed to load image into kind cluster${NC}"
        exit 1
    fi
else
    echo -e "\n${YELLOW}Step 2: Skipping kind load (not using kind cluster)${NC}"
fi

# Step 3: Deploy with Helm
echo -e "\n${GREEN}Step 3: Deploying with Helm...${NC}"

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Deploy with Helm
helm upgrade --install webhook-cronjob ./helm \
    --namespace $NAMESPACE \
    --values helm/values.yaml \
    --set image.tag=$IMAGE_TAG \
    --wait \
    --timeout 300s

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Application deployed successfully${NC}"
else
    echo -e "${RED}✗ Failed to deploy application${NC}"
    exit 1
fi

# Step 4: Show status
echo -e "\n${GREEN}Step 4: Checking deployment status...${NC}"
kubectl get cronjob -n $NAMESPACE
echo
kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=webhook-cronjob

echo -e "\n${GREEN}Deployment completed successfully!${NC}"
echo -e "${YELLOW}To view logs:${NC} kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=webhook-cronjob"
echo -e "${YELLOW}To view cronjob status:${NC} kubectl get cronjob -n $NAMESPACE webhook-cronjob"
