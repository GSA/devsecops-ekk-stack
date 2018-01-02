module "ekk_stack" {
  source = "../"
  s3_logging_bucket_name = "${var.s3_logging_bucket_name}"
  ec_test_instance_key_name = "${var.ec_test_instance_key_name}"
}

data "template_file" "user_data_template" {
  depends_on = ["aws_kinesis_firehose_delivery_stream.extended_s3_stream"]
  template = "${file("${path.module}/files/ec2-test.tpl")}"

  vars {
    deliverystream = "${var.es_kinesis_delivery_stream}"
  }
}

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