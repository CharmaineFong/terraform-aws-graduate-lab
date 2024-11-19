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

variable "asg_min_size" {
  description = "min number of instance scaled in by ASG"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "max number of instance scaled out by ASG"
  type        = number
  default     = 5
}

variable "asg_desired_capacity" {
  description = "desired number of instance to run by ASG"
  type        = number
  default     = 2
}
