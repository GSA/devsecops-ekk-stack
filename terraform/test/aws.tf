data "aws_region" "current" {
  current = true
}

provider "aws" {
  version = "~> 1.8"
}
