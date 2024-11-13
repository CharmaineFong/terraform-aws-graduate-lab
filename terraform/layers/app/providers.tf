terraform {
  required_version = "~> 1.5.5"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# 1. Set common default tags to deployed resources
# use variables defined in terraform.tfvars to allow for dynamic tagging
# 2. Specify region to be used across all tf files
provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      project_name = var.project_name
      environment  = var.environment
      owner        = var.owner
      CreatedBy    = "Terraform"
    }
  }
}
