#!/bin/bash

# Configuration
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Set values
ECR_REPOSITORY="voice-ai-agent"
CLUSTER_NAME="voice-ai-cluster"
SERVICE_NAME="voice-ai-service"
ECR_REPOSITORY_PREFIX="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
ECR_REPOSITORY_URL="$ECR_REPOSITORY_PREFIX/$ECR_REPOSITORY"

echo "Starting deployment to ECS..."

# ECR repository already created by OpenTofu
echo "Using ECR repository: $ECR_REPOSITORY_URL"

# Get ECR login token
echo "Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY_PREFIX

# Build and tag Docker image
echo "Building Docker image..."
docker build -t $ECR_REPOSITORY .
docker tag $ECR_REPOSITORY:latest $ECR_REPOSITORY_URL:latest

# Push image to ECR
echo "Pushing image to ECR..."
docker push $ECR_REPOSITORY_URL:latest

# Create/update task definition
echo "Creating task definition..."
cd infrastructure
SECRETS_ARN=$(tofu output -raw secrets_manager_arn)
EXECUTION_ROLE_ARN=$(tofu output -raw ecs_execution_role_arn)
ECR_URL=$(tofu output -raw ecr_repository_url)
cd ..

# Update task definition with actual values
sed "s|<account-id>|$AWS_ACCOUNT_ID|g; s|<region>|$AWS_REGION|g; s|\${SECRETS_ARN}|$SECRETS_ARN|g; s|<execution-role-arn>|$EXECUTION_ROLE_ARN|g; s|<ecr-url>|$ECR_URL|g" ecs-task-definition.json > ecs-task-definition-updated.json

# Register task definition
echo "Registering task definition..."
aws ecs register-task-definition --cli-input-json file://ecs-task-definition-updated.json --region $AWS_REGION

# Update ECS service to use new task definition
echo "Updating ECS service..."
aws ecs update-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --task-definition voice-ai-agent --desired-count 1 --force-new-deployment --region $AWS_REGION

echo "Deployment completed successfully!"
echo "Your voice AI agent is now running on ECS."