output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "secrets_manager_arn" {
  description = "Secrets Manager ARN for API keys"
  value       = aws_secretsmanager_secret.api_keys.arn
}

output "ecs_execution_role_arn" {
  description = "ECS Task Execution Role ARN"
  value       = aws_iam_role.ecs_execution.arn
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.ecs.id
}

output "ecs_service_name" {
  description = "ECS Service name"
  value       = aws_ecs_service.app.name
}

output "aws_region" {
  description = "AWS Region"
  value       = var.aws_region
}