# Deploy an autoscaling group to manage the 
# number of web servers used by my application

# TF Code added to app layer asg.tf
# image_id obtained by using data source to retrieve latest AMI ID
# src folder copied from ~/src/lab1 to app layer
# Launch Template configured to use user data script ec2WebUserData.tftpl
# ASG Configuration matches lab requirements

# Amazon Linux 2 AMIs and sized as t2.micro
data "aws_ami" "latest_linux_2_AMI" {
  most_recent = true

  owners = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
