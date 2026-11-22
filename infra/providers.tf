terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "vaultbridge-lab"

  allowed_account_ids = [var.allowed_account_id]

  default_tags {
    tags = {
      Project     = "VaultBridge-IaC"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}

