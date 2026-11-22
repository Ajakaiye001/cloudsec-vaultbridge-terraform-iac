terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region  = "eu-north-1"
  profile = "vaultbridge-lab"

  allowed_account_ids = [var.allowed_account_id]

}

data "aws_caller_identity" "current" {

  # Generate a unique suffix for the S3 bucket name.
}
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 bucket for Terraform remote state.
resource "aws_s3_bucket" "terraform_state" {
  bucket = "vaultbridge-tfstate-${data.aws_caller_identity.current.account_id}-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "VaultBridge Terraform State"
    Project     = "VaultBridge"
    Environment = "Lab"
    ManagedBy   = "Terraform"
  }
}
# Enable versioning for state recovery.
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption.
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access.
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# Enforce bucket-owner control.
resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
