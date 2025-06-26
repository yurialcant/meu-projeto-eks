terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    bucket = "meuprojetoeks"
    key    = "projeto-eks/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Módulo VPC (workspace vpc)
module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  availability_zones = var.availability_zones

  # Só cria se o workspace for vpc
  count = terraform.workspace == "vpc" ? 1 : 0
}

# Remote state para EKS (workspace eks)
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "meuprojetoeks"
    key    = "env:/vpc/projeto-eks/terraform.tfstate"
    region = "us-east-1"
  }
}

# Módulo EKS
module "eks" {
  source = "./modules/eks"

  project_name = var.project_name
  cluster_name = "meu-cluster-de-teste"

  vpc_id             = terraform.workspace == "eks" ? data.terraform_remote_state.vpc.outputs.vpc_id : null
  private_subnet_ids = terraform.workspace == "eks" ? data.terraform_remote_state.vpc.outputs.private_subnet_ids : null
  public_subnet_ids  = terraform.workspace == "eks" ? data.terraform_remote_state.vpc.outputs.public_subnet_ids : null

  count = terraform.workspace == "eks" ? 1 : 0
}

data "terraform_remote_state" "eks" {
  count = contains(["eks", "app"], terraform.workspace) ? 1 : 0

  backend = "s3"

  config = {
    bucket = "meuprojetoeks" 
    key    = "env:/eks/projeto-eks/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_ecr_repository" "app" {
  count = terraform.workspace == "app" ? 1 : 0

  name                 = "${var.project_name}-app-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

provider "helm" {
  kubernetes {
    host                   = terraform.workspace == "app" && length(data.terraform_remote_state.eks) > 0 ? data.terraform_remote_state.eks[0].outputs.cluster_endpoint : ""
    cluster_ca_certificate = terraform.workspace == "app" && length(data.terraform_remote_state.eks) > 0 ? base64decode(data.terraform_remote_state.eks[0].outputs.cluster_certificate_authority_data) : ""
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = terraform.workspace == "app" && length(data.terraform_remote_state.eks) > 0 ? ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks[0].outputs.cluster_name] : []
    }
  }
}

provider "kubernetes" {
  host                   = terraform.workspace == "app" && length(data.terraform_remote_state.eks) > 0 ? data.terraform_remote_state.eks[0].outputs.cluster_endpoint : ""
  cluster_ca_certificate = terraform.workspace == "app" && length(data.terraform_remote_state.eks) > 0 ? base64decode(data.terraform_remote_state.eks[0].outputs.cluster_certificate_authority_data) : ""
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = terraform.workspace == "app" && length(data.terraform_remote_state.eks) > 0 ? ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks[0].outputs.cluster_name] : []
  }
}

# Módulo de deploy da aplicação (aplica só no workspace "app")
module "app_deploy" {
  source = "./modules/app_deploy"
  count  = terraform.workspace == "app" && length(data.terraform_remote_state.eks) > 0 ? 1 : 0

  app_image_uri = aws_ecr_repository.app[0].repository_url
}