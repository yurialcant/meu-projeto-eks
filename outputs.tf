output "vpc_id" {
  value = terraform.workspace == "vpc" ? module.vpc[0].vpc_id : null
}

output "private_subnet_ids" {
  value = terraform.workspace == "vpc" ? module.vpc[0].private_subnet_ids : null
}

output "public_subnet_ids" {
  value = terraform.workspace == "vpc" ? module.vpc[0].public_subnet_ids : null
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = terraform.workspace == "app" ? aws_ecr_repository.app[0].repository_url : null
}

output "application_url" {
  description = "The final URL for the deployed application"
  value       = terraform.workspace == "app" && length(module.app_deploy) > 0 ? module.app_deploy[0].application_url : null
}