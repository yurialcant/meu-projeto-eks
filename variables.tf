variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "A name for the project to prefix resources."
  type        = string
  default     = "eks-hello-world"
}

variable "availability_zones" {
  description = "List of availability zones for the VPC."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  
}