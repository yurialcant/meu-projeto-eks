terraform {
  required_version = ">= 1.0" // Especifique a versão do Terraform

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }


  // CONFIGURAÇÃO DO BACKEND S3
  backend "s3" {
    bucket   = "meuprojetoeks"
    key      = "projeto-eks/terraform.tfstate"      // Caminho dentro do bucket. O Terraform criará subdiretórios para cada workspace aqui.
    region   = "us-east-1"                          
    encrypt  = true                                 // Habilita criptografia do lado do servidor
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc" // Caminho para o módulo

  project_name = var.project_name
}
