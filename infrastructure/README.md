# Infrastructure Deployment

This directory contains OpenTofu configuration to deploy the minimal AWS infrastructure for the voice AI agent.

## Prerequisites
- OpenTofu installed
- AWS CLI configured with appropriate permissions
- An existing ACM certificate for HTTPS/WSS support

## Quick Start

1. **Copy and configure variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your actual API keys
   ```

2. **Deploy infrastructure**:
   ```bash
   ./deploy-infra.sh
   ```

3. **Build and deploy application**:
   ```bash
   cd ..
   ./deploy.sh
   ```

## Task Definition Management
Task definitions are managed during deployment:
- `../deploy.sh` - Full deployment pipeline (includes task definition updates)

## What's Created
- VPC with 2 public subnets
- Internet Gateway and routing
- Security groups for ALB and ECS
- Application Load Balancer with HTTPS listener
- ECS Fargate cluster
- ECR repository
- CloudWatch log group
- AWS Secrets Manager for API keys
- IAM execution role with Secrets Manager access
- ECS service (starts with placeholder, updated during deployment)

**Note**: Task definitions are managed separately via scripts.

## Clean Up
```bash
tofu destroy
```