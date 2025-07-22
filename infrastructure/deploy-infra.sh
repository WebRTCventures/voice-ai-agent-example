#!/bin/bash

set -e
set -x

echo "Deploying infrastructure with OpenTofu..."

# Initialize OpenTofu
echo "Initializing OpenTofu..."
tofu init

# Plan the deployment
echo "Planning deployment..."
tofu plan

# Apply the infrastructure
echo "Applying infrastructure..."
tofu apply -auto-approve

# Get outputs
echo "Getting infrastructure outputs..."
ECR_URL=$(tofu output -raw ecr_repository_url)
CLUSTER_NAME=$(tofu output -raw ecs_cluster_name)
APP_URL=$(tofu output -raw application_url)
WS_URL=$(tofu output -raw websocket_url)

echo ""
echo "Infrastructure deployed successfully!"
echo "ECR Repository URL: $ECR_URL"
echo "ECS Cluster Name: $CLUSTER_NAME"
echo "Application URL: $APP_URL"
echo "WebSocket URL: $WS_URL"
echo ""
echo "Next steps:"
echo "1. Build and push your Docker image to: $ECR_URL"
echo "2. Update ECS service to use the new image"
echo "3. Configure your Twilio webhook to: $APP_URL"