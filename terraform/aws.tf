provider "aws" {
    version = "~> 1.3"
    region = "${var.aws_region}"
  }
  
  terraform {
    backend "s3" {
    }
  }