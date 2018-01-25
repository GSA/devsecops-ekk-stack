# IAM roles and policies for this stack

# Policies

data "template_file" "ec2_assume_role_policy" {
  template = "${file("${path.module}/policies/ec2_assume_role.json")}"
}

data "template_file" "firehose_assume_role_policy" {
  template = "${file("${path.module}/policies/firehose_assume_role.json")}"
}

data "template_file" "elasticsearch_policy" {
  template = "${file("${path.module}/policies/elasticsearch_policy.json")}"
}

# S3
resource "aws_iam_role" "s3_delivery_role" {
    name = "${var.s3_delivery_role_name}"
    assume_role_policy = "${data.template_file.firehose_assume_role_policy.rendered}"
}

data "aws_iam_policy_document" "s3_log_bucket_access" {
  statement {
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::${var.s3_logging_bucket_name}",
    ]
  }
}

resource "aws_iam_policy" "s3_log_bucket_iam_policy" {
  name   = "${var.s3_role_log_bucket_access_policy}"
  path   = "/"
  policy = "${data.aws_iam_policy_document.s3_log_bucket_access.json}"
}

resource "aws_iam_role" "ekk_role" {
    name = "${var.ekk_role_name}"
    assume_role_policy = "${data.template_file.ec2_assume_role_policy.rendered}"
}

resource "aws_iam_instance_profile" "ekk_instance_profile" {
  name  = "${var.ekk_role_name}-instance-profile"
  role = "${aws_iam_role.ekk_role.name}"
}

resource "aws_iam_policy" "ekk_policy" {
    name = "${var.ekk_role_policy_name}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics",
        "cloudwatch:PutMetricAlarm",
        "cloudwatch:PutMetricData",
        "cloudwatch:SetAlarmState",
        "kms:GenerateDataKey"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
        "Action": [
            "kms:GenerateDataKey",
            "kms:Encrypt",
            "kms:Decrypt"
        ],
        "Effect": "Allow",
        "Resource": "${var.ekk_kinesis_stream_kms_key_arn != "" ? var.ekk_kinesis_stream_kms_key_arn : aws_kms_key.kinesis_stream_kms_key.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ekk_policy_attach" {
    role = "${aws_iam_role.ekk_role.name}"
    policy_arn = "${aws_iam_policy.ekk_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "es_full_access" {
    role = "${aws_iam_role.ekk_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonESFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
    role = "${aws_iam_role.ekk_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "kinesisfirehouse_full_access" {
    role = "${aws_iam_role.ekk_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFirehoseFullAccess"
}

resource "aws_iam_role_policy_attachment" "kinesis_stream_full_access" {
    role = "${aws_iam_role.ekk_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFullAccess"
}

resource "aws_iam_role_policy_attachment" "es_cloudwatch_full_access" {
    role = "${aws_iam_role.ekk_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role" "elasticsearch_delivery_role" {
    name = "${var.es_delivery_role_name}"
    assume_role_policy = "${data.template_file.firehose_assume_role_policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "es_delivery_full_access" {
    role = "${aws_iam_role.elasticsearch_delivery_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonESFullAccess"
}