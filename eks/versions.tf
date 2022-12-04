terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.4.1"
    }
  }

  backend "s3" {
    bucket         = "demo-eks-terraform-remote-state-rnhvgvat-s3"
    key            = "demo-eks.tfstate"
    region         = "ap-southeast-2"
    encrypt        = "true"
    dynamodb_table = "demo-eks-terraform-remote-state-rnhvgvat-dynamodb"
  }
}
