# data source to assume IAM role policy
data "aws_iam_policy_document" "ec2_instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create instance IAM role
resource "aws_iam_role" "ec2_instance_iam_role" {
  name               = "${var.project_name}-${var.environment}-ec2-instance-iam-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_instance_assume_role_policy.json
}


# IAM Policy restricts access to only S3 Bucket hosting web server files
# IAM Policy restricted to S3 Actions that permit copying files to EC2 only
resource "aws_iam_role_policy" "s3_to_ec2_policy" {
  name = "${var.project_name}-${var.environment}-s3-to-ec2-policy"
  role = aws_iam_role.ec2_instance_iam_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowListAndReadS3Objects",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          # reference data block directly from s3.tf to fetch s3 arn
          data.aws_s3_bucket.grad_lab_1_webstie_files_bucket.arn,
          "${data.aws_s3_bucket.grad_lab_1_webstie_files_bucket.arn}/*"
        ]
      }
    ]
  })
}



# Create IAM instance profile
resource "aws_iam_instance_profile" "EC2_instance_profile" {
  name = "${var.project_name}-${var.environment}-ec2-instance-profile"
  role = aws_iam_role.ec2_instance_iam_role.name
}
