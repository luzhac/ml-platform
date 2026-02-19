terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.64" }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  description = "AWS region to deploy"
  type        = string
  default     = "eu-west-2"
}

# S3 bucket for terraform state

resource "aws_s3_bucket" "s3_for_terraform" {
  bucket = "marscompute-s3-terraform-state-ml"
  tags = {
    Name = "terraform-state"
  }

  lifecycle {
    prevent_destroy = true
  }

}

resource "aws_s3_bucket_versioning" "versioning_s3_for_terraform" {
  bucket = aws_s3_bucket.s3_for_terraform.id
  versioning_configuration {
    status = "Enabled"
  }
}


 