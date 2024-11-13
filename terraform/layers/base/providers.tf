terraform {
  required_version = "~> 1.5.5"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Set common default tags to deployed resources
# use variables defined in terraform.tfvars to allow for dynamic tagging
provider "aws" {
  default_tags {
    tags = {
      project_name = var.project_name
      environment  = var.environment
      owner        = var.owner
      CreatedBy    = "Terraform"
    }
  }
}
