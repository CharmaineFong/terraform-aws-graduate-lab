# target vpc - filter by name tag
data "aws_vpc" "grad_lab_1_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-${var.environment}-vpc"] # insert values here
  }
}

# target public subnets - filter by vpc id and subnet name tag
data "aws_subnet" "grad_lab_1_public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.grad_lab_1_vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-${var.environment}-vpc-public-*"]
  }
}

# provision alb
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name = "${var.project_name}-${var.environment}-alb"

  vpc_id  = data.aws_vpc.grad-lab-1-vpc.id
  subnets = data.aws_subnet.grad_lab_1_public_subnets.ids

  create_security_group = false
  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      description = "Allow egress for all ports"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  access_logs = {
    bucket = "${var.project_name}-${var.environment}-alb-logs"
  }

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"

      forward = {
        target_group_key = "ex-instance"
      }
    }
  }

  target_groups = {
    ex-instance = {
      name_prefix = "h1"
      protocol    = "HTTP"
      port        = 80
      target_type = "instance"
      target_id   = "i-0f6d38a07d50d080f"
    }
  }

}
