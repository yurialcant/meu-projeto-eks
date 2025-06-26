variable "project_name" {
  description = "Name of the project, used to tag resources."
  type        = string
}

variable "cluster_name" {
  description = "Name for the EKS cluster."
  type        = string
  default     = "hello-world-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "The ID of the VPC where the cluster will be deployed."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the worker nodes."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the cluster control plane."
  type        = list(string)
  default     = []
}

variable "instance_types" {
  description = "List of EC2 instance types for the node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 3
}

variable "min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1
}