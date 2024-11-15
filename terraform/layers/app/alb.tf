# target vpc - filter by name tag
data "aws_vpc" "grad_lab_1_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-${var.environment}-vpc"] # insert values here
  }
}

# target public subnets - filter by vpc id and subnet name tag
data "aws_subnets" "grad_lab_1_public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.grad_lab_1_vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-${var.environment}-vpc-public-*"]
  }
}

# create security group for ALB - include sg rules
resource "aws_security_group" "grad_lab_1_alb_sg" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = data.aws_vpc.grad_lab_1_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTPS_ingress_traffic" {
  security_group_id = aws_security_group.grad_lab_1_alb_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTP_ingress_traffic" {
  security_group_id = aws_security_group.grad_lab_1_alb_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_traffic" {
  security_group_id = aws_security_group.grad_lab_1_alb_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# provision alb
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "${var.project_name}-${var.environment}-alb"

  vpc_id                = data.aws_vpc.grad_lab_1_vpc.id
  subnets               = data.aws_subnets.grad_lab_1_public_subnets.ids
  create_security_group = false
  security_groups       = [aws_security_group.grad_lab_1_alb_sg.id]

  target_groups = [
    {
      name_prefix      = "web-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      health_check = {
        path                = "/"
        port                = 80
        matcher             = "200"
        interval            = 120
        unhealthy_threshold = 5
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

}
