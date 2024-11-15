module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${var.project_name}-${var.environment}-ec2-web-files"

  versioning = {
    enabled = true
  }
}
