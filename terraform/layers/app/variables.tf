# Define variables that will be used across the Terraform configurations
variable "environment" {
  description = "Define environment to deploy resources in"
  type        = string
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
