terraform {
  required_version = "~> 1.9.8"

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


# declare local variables - global throughout layer  
# the reason why this variable is in the providers.tf is becayse 
# the data block referencing it in vpc.tf is calling an external resource (aws provider in this case) 
# to retrieve availability zones information
locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
}
