terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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

  # Só tenta ler se não for workspace vpc
  # (Não há "count", a leitura é condicional no uso)
}

# Módulo EKS
module "eks" {
  source = "./modules/eks"

  project_name = var.project_name
  cluster_name = "meu-cluster-de-teste"

  vpc_id             = terraform.workspace == "eks" ? data.terraform_remote_state.vpc.outputs.vpc_id : null
  private_subnet_ids = terraform.workspace == "eks" ? data.terraform_remote_state.vpc.outputs.private_subnet_ids : null

  count = terraform.workspace == "eks" ? 1 : 0
}
