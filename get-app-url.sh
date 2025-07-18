#!/bin/bash

# Get values from OpenTofu outputs
cd infrastructure
CLUSTER_NAME=$(tofu output -raw ecs_cluster_name)
SERVICE_NAME=$(tofu output -raw ecs_service_name)
AWS_REGION=$(tofu output -raw aws_region || echo "us-east-1")
cd ..

echo "Getting application access information..."

# Get running task ARN
TASK_ARN=$(aws ecs list-tasks --cluster $CLUSTER_NAME --service-name $SERVICE_NAME --desired-status RUNNING --region $AWS_REGION --query 'taskArns[0]' --output text)

if [ "$TASK_ARN" = "None" ] || [ -z "$TASK_ARN" ]; then
    echo "No running tasks found. Make sure the service is deployed and running."
    exit 1
fi

# Get task details including network interface
NETWORK_INTERFACE_ID=$(aws ecs describe-tasks --cluster $CLUSTER_NAME --tasks $TASK_ARN --region $AWS_REGION --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' --output text)

# Get public IP from network interface
PUBLIC_IP=$(aws ec2 describe-network-interfaces --network-interface-ids $NETWORK_INTERFACE_ID --region $AWS_REGION --query 'NetworkInterfaces[0].Association.PublicIp' --output text)

if [ "$PUBLIC_IP" = "None" ] || [ -z "$PUBLIC_IP" ]; then
    echo "No public IP found for the task."
    exit 1
fi

echo ""
echo "Application Access Information:"
echo "================================"
echo "Public IP: $PUBLIC_IP"
echo "HTTP URL: http://$PUBLIC_IP:8000"
echo "WebSocket URL: ws://$PUBLIC_IP:8000/ws"
echo "TwiML Endpoint: http://$PUBLIC_IP:8000/"
echo ""
echo "Configure your Twilio webhook to: http://$PUBLIC_IP:8000/"