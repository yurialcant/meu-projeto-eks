output "vpc_id" {
  value = terraform.workspace == "vpc" ? module.vpc[0].vpc_id : null
}

output "private_subnet_ids" {
  value = terraform.workspace == "vpc" ? module.vpc[0].private_subnet_ids : null
}

output "public_subnet_ids" {
  value = terraform.workspace == "vpc" ? module.vpc[0].public_subnet_ids : null
}

