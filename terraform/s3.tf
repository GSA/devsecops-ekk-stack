resource "aws_s3_bucket" "s3_logging_bucket" {
  bucket = "${var.s3_logging_bucket_name}"
  acl    = "private"
}