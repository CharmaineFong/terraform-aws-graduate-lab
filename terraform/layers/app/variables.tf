# Define variables that will be used across the Terraform configurations
variable "environment" {
  description = "Define environment to deploy resources in"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Define project name"
  type        = string
}

variable "owner" {
  description = "Owner of deployed resource"
  type        = string
  default     = "Andy"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
