# Seploy an autoscaling group to manage the number of web servers used by my application

# TF Code added to app layer asg.tf
# image_id obtained by using data source to retrieve latest AMI ID
# src folder copied from ~/src/lab1 to app layer
# Launch Template configured to use user data script ec2WebUserData.tftpl
# ASG Configuration matches lab requirements


# ----------------------- Launch template with Linux 2 AMI
# Amazon Linux 2 AMIs ID
data "aws_ami" "latest_linux_2_AMI" {
  most_recent = true

  owners = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Launch Template configured to use user data script ec2WebUserData.tftpl
resource "aws_launch_template" "grad_lab_1_asg_launch_temp" {
  name                   = "${var.project_name}-${var.environment}-instance-launch-template"
  image_id               = data.aws_ami.latest_linux_2_AMI.image_id
  instance_type          = var.ec2_web_instance_type
  vpc_security_group_ids = [aws_security_group.grad_lab_1_asg_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.EC2_instance_profile.name
  }

  user_data = base64encode(templatefile("./src/ec2WebUserData.tftpl"),
    {
      bucket_name = data.aws_s3_bucket.grad_lab_1_webstie_files_bucket.name
  })
}

# -------------------- ASG

# all subnets - filter by vpc id and subnet name tag
data "aws_subnets" "grad_lab_1_all_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.grad_lab_1_vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-${var.environment}-vpc-*"]
  }
}

# placement group
resource "aws_placement_group" "grad_lab_1_asg_pg" {
  name     = "${var.project_name}-${var.environment}-placement-group"
  strategy = "spread"
}

# create autoscaling group
resource "aws_autoscaling_group" "grad_lab_1_asg" {
  name = "${var.project_name}-${var.environment}-asg"

  desired_capacity = var.asg_desired_capacity
  max_size         = var.asg_max_size
  min_size         = var.asg_min_size

  placement_group     = aws_placement_group.grad_lab_1_asg_pg.id
  target_group_arns   = module.alb.target_group_arns
  vpc_zone_identifier = data.aws_subnets.grad_lab_1_all_subnets.ids
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.grad_lab_1_asg_launch_temp.id
    version = "$Latest"
  }
}


# ------------------------- Security Group for ASG

# create Security group for ASG
resource "aws_security_group" "grad_lab_1_asg_sg" {
  name        = "${var.project_name}-${var.environment}-asg-sg"
  description = "Security group for asg"
  vpc_id      = data.aws_vpc.grad_lab_1_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "asg_allow_HTTPS_ingress_traffic" {
  security_group_id            = aws_security_group.grad_lab_1_asg_sg.id
  referenced_security_group_id = module.alb.security_group_id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}

resource "aws_vpc_security_group_ingress_rule" "asg_allow_HTTP_ingress_traffic" {
  security_group_id            = aws_security_group.grad_lab_1_asg_sg.id
  referenced_security_group_id = module.alb.security_group_id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "asg_allow_s3_endpoint_egress_traffic" {
  security_group_id = aws_security_group.grad_lab_1_asg_sg.id
  # points to group of S3 gatway endpoint IP addresses
  prefix_list_id = aws_vpc_endpoint.s3_gateway_endpoint.prefix_list_id
  ip_protocol    = "-1"
}

# ------------------------- vpc - aws s3 gateway endpoint
resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_id            = data.aws_vpc.grad_lab_1_vpc.id
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc-endpoint-s3"
  }
}
