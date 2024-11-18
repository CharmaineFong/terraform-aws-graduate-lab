# Deploy an autoscaling group to manage the 
# number of web servers used by my application

# TF Code added to app layer asg.tf
# image_id obtained by using data source to retrieve latest AMI ID
# src folder copied from ~/src/lab1 to app layer

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

# Launch Template configured to use user data script ec2WebUserData.tftpl
resource "aws_launch_template" "grad_lab_1_asg_launch_temp" {
  name          = "${var.project_name}-${var.environment}-instance-launch-template"
  image_id      = data.aws_ami.latest_linux_2_AMI.image_id
  instance_type = "t2.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.EC2_instance_profile.name
  }

  user_data = base64encode(templatefile("./src/ec2WebUserData.tftpl"),
    {
      bucket_name = "${var.project_name}-${var.environment}-website-files"
  })
}
