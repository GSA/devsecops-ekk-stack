module "test_vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc"

#   name = "${var.vpc_name}"

#   cidr = "${var.vpc_cidr}"
#   public_subnets  = ["${var.app_public_subnet_cidrs}"]
#   private_subnets = ["${var.app_private_subnet_cidrs}"]
#   database_subnets = ["${var.database_subnet_cidrs}"]

#   enable_nat_gateway = "${var.enable_nat_gateway}"
#   enable_dns_hostnames = "${var.enable_dns_hostnames}"
#   enable_dns_support = "${var.enable_dns_support}"

#   azs = ["${var.aws_az1}", "${var.aws_az2}"]

#   create_database_subnet_group = "${var.create_database_subnet_group}"

name = "ec2-test"
cidr = "10.0.0.0/16"
public_subnets = ["10.0.1.0/24"]
enable_nat_gateway = "false"
enable_dns_hostnames = "true"
enable_dns_support = "true"
azs = ["us-east-1c", "us-east-1d"]
}

data "template_file" "user_data_template" {
  depends_on = ["aws_kinesis_firehose_delivery_stream.extended_s3_stream"]
  template = "${file("${path.module}/files/ec2-test.tpl")}"

  vars {
    deliverystream = "${var.es_kinesis_delivery_stream}"
  }
}

# resource "local_file" "user_data_rendered" {
#     content = "${data.template_file.user_data_template.rendered}"
#     filename = "${path.module}/files/ec2-test.sh"
# }

data "aws_ami" "ec2-linux" {
  most_recent = true
  filter {
    name = "name"
    values = ["amzn-ami-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name = "owner-alias"
    values = ["amazon"]
  }
}

resource "aws_security_group" "main" {
  vpc_id = "${module.test_vpc.vpc_id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "stream_tester" {
  ami           = "${data.aws_ami.ec2-linux.id}"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.elasticsearch_instance_profile.id}"

  subnet_id = "${module.test_vpc.public_subnets[0]}"
  vpc_security_group_ids = ["${aws_security_group.main.id}"]

  key_name = "${var.ec_test_instance_key_name}"

  user_data = "${data.template_file.user_data_template.rendered}"

  provisioner "remote-exec" {
    inline = ["echo Successfully connected"]

    connection {
      user = "ec2-user"
    }
  }
}