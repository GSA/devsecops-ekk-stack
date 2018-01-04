module "test_vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc"

  name = "ec2-test"
  cidr = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24"]
  enable_nat_gateway = "false"
  enable_dns_hostnames = "true"
  enable_dns_support = "true"
  azs = ["us-east-1c", "us-east-1d"]
}