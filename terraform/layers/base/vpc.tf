# data blocks variables should be seperately stored
data "aws_availability_zones" "available" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project_name}-${var.environment}-vpc"
  cidr = var.vpc_cidr_range

  azs = local.azs
  # calculate the subnet address using the cidrsubnet function for reusability
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr_range, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr_range, 8, 100 + k)]

  enable_nat_gateway = true
  # assign signle nat gateway dynamically based on environment --> improve reusability 
  single_nat_gateway = var.environment == "dev" ? true : false

}

# configure a S3 Gateway endpoint so my EC2 Instances can access S3 directly from my VPC
# Configure with private_route_table_ids
# Endpoint type = Gateway
module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      # interface endpoint
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags = {
        Name = "${var.project_name}-${var.environment}-s3-vpc-endpoint"
      }
    },
  }
}
