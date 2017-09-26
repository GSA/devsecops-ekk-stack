# IAM roles and policies for this stack

# S3
resource "aws_iam_role" "s3_delivery_role" {
    name = "${var.s3_delivery_role_name}"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "firehose.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
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

# ElasticSearch
resource "aws_iam_role" "elasticsearch_role" {
    name = "${var.elasticsearch_role_name}"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "elasticsearch_policy" {
    name = "${var.elasticsearch_role_policy_name}"
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
        "cloudwatch:SetAlarmState"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "elasticsearch_policy_attach" {
    role = "${aws_iam_role.elasticsearch_role.name}"
    policy_arn = "${aws_iam_policy.elasticsearch_policy.arn}"
}

resource "aws_iam_role_policy_attachment" "es_full_access" {
    role = "${aws_iam_role.elasticsearch_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonESFullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
    role = "${aws_iam_role.elasticsearch_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "es_kinesisfirehouse_full_access" {
    role = "${aws_iam_role.elasticsearch_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFirehoseFullAccess"
}
resource "aws_iam_role_policy_attachment" "es_cloudwatch_full_access" {
    role = "${aws_iam_role.elasticsearch_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role" "elasticsearch_delivery_role" {
    name = "${var.es_delivery_role_name}"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "firehose.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "es_delivery_full_access" {
    role = "${aws_iam_role.elasticsearch_delivery_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonESFullAccess"
}