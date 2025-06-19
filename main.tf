terraform {
  required_version = ">= 1.0" // Especifique a versão do Terraform que você usará

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }


backend "s3" {
  bucket = "seu-bucket-tfstate-aqui"
 key    = "global/s3/terraform.tfstate" 
 region = var.aws_region
 encrypt = true 
 }
}

provider "aws" {
  region = var.aws_region
}
