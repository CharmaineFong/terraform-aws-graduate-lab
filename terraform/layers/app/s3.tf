data "aws_s3_bucket" "grad_lab_1_webstie_files_bucket" {
  bucket = "${var.project_name}-${var.environment}-ec2-website-files"
}

resource "aws_s3_object" "s3_web_files_objects" {
  key    = "index.html"
  bucket = data.aws_s3_bucket.grad_lab_1_webstie_files_bucket.id
  source = "./src/index.html"
}
