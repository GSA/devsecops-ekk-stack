resource "aws_kms_key" "s3_logging_kms_key" {
    count = "${var.s3_kms_key_arn == "" ? 1 : 0}"

    description = "S3 Logging KMS Key - Created by Terraform"
}

resource "aws_kms_key" "kinesis_stream_kms_key" {
    count = "${var.ekk_kinesis_stream_kms_key_id == "" ? 1 : 0}"

    description = "Kinesis Stream KMS Key - Created by Terraform"
}

# resource "aws_elasticsearch_domain" "elasticsearch" {
#   domain_name = "${var.es_domain_name}"
#   elasticsearch_version = "${var.es_version}"
  
#   cluster_config {
#       dedicated_master_enabled = "${var.es_dedicated_master_enabled}"
#       instance_type = "${var.es_instance_type}"
#       instance_count = "${var.es_instance_count}"
#       zone_awareness_enabled = "${var.es_zone_awareness_enabled}"
#       dedicated_master_type = "${var.es_dedicated_master_instance_type}"
#       dedicated_master_count = "${var.es_dedicated_master_count}"
#   }

#   advanced_options {
#       "rest.action.multi.allow_explicit_index" = "${var.es_advanced_allow_explicit_index}"
#   }

#   ebs_options {
#       ebs_enabled = "${var.es_ebs_enabled}"
#       iops = "${var.es_ebs_iops}"
#       volume_size = "${var.es_ebs_volume_size}"
#       volume_type = "${var.es_ebs_volume_type}"
#   }

#   snapshot_options {
#       automated_snapshot_start_hour = "${var.es_snapshot_start_hour}"
#   }

#     access_policies = <<CONFIG
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "es:*",
#             "Principal": "*",
#             "Effect": "Allow",
#             "Resource": "*"
#         }
#     ]
# }
# CONFIG
# }

# IAM roles and policies for this stack

# Policies

data "template_file" "ec2_assume_role_policy" {
  template = "${file("${path.module}/policies/ec2_assume_role.json")}"
}

data "template_file" "firehose_assume_role_policy" {
  template = "${file("${path.module}/policies/firehose_assume_role.json")}"
}

# data "template_file" "elasticsearch_policy" {
#   template = "${file("${path.module}/policies/elasticsearch_policy.json")}"
# }

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
        "cloudwatch:SetAlarmState"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ekk_policy_attach" {
    role = "${aws_iam_role.ekk_role.name}"
    policy_arn = "${aws_iam_policy.ekk_policy.arn}"
}

# resource "aws_iam_role_policy_attachment" "es_full_access" {
#     role = "${aws_iam_role.elasticsearch_role.name}"
#     policy_arn = "arn:aws:iam::aws:policy/AmazonESFullAccess"
# }

resource "aws_iam_role_policy_attachment" "s3_full_access" {
    role = "${aws_iam_role.ekk_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "kinesisfirehouse_full_access" {
    role = "${aws_iam_role.ekk_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFirehoseFullAccess"
}

resource "aws_iam_role_policy_attachment" "es_cloudwatch_full_access" {
    role = "${aws_iam_role.ekk_role.name}"
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

# resource "aws_iam_role" "elasticsearch_delivery_role" {
#     name = "${var.es_delivery_role_name}"
#     assume_role_policy = "${data.template_file.firehose_assume_role_policy.rendered}"
# }

# resource "aws_iam_role_policy_attachment" "es_delivery_full_access" {
#     role = "${aws_iam_role.elasticsearch_delivery_role.name}"
#     policy_arn = "arn:aws:iam::aws:policy/AmazonESFullAccess"
# }

resource "aws_kinesis_stream" "ekk_kinesis_stream" {
    name = "${var.ekk_kinesis_stream_name}"
    shard_count = "${var.ekk_kinesis_stream_shard_count}"
    retention_period = "${var.ekk_kinesis_stream_retention_period}"

    # shard_level_metrics = [
    # "IncomingBytes",
    # "OutgoingBytes",
    # ]

    shard_level_metrics = "${var.ekk_kinesis_stream_shard_metrics}"

    encryption_type = "KMS"
    # Strangely, this uses the KMS GUID instead of the ARN
    kms_key_id = "${var.ekk_kinesis_stream_kms_key_id}"
    kms_key_id = "${var.ekk_kinesis_stream_kms_key_id != "" ? ekk_kinesis_stream_kms_key_id : aws_kms_key.kinesis_stream_kms_key.key_id}"
}

resource "aws_kinesis_firehose_delivery_stream" "ekk_kinesis_delivery_stream" {
    name = "${var.kinesis_delivery_stream}"
    destination = "s3"
    kinesis_source_configuration = "${aws_kinesis_stream.ekk_kinesis_stream.arn}"
    # destination = "elasticsearch"
    
    # elasticsearch_configuration {
    #     buffering_interval = "${var.es_buffering_interval}"
    #     buffering_size = "${var.es_buffering_size}"
    #     cloudwatch_logging_options {
    #         enabled = "${var.es_cloudwatch_logging_enabled}"
    #         log_group_name = "${aws_cloudwatch_log_group.es_log_group.name}"
    #         log_stream_name = "${aws_cloudwatch_log_stream.es_log_stream.name}"
    #     }
    #     domain_arn = "${aws_elasticsearch_domain.elasticsearch.arn}"
    #     role_arn = "${aws_iam_role.elasticsearch_delivery_role.arn}"
    #     index_name = "${var.es_index_name}"
    #     type_name = "${var.es_type_name}"
    #     index_rotation_period = "${var.es_index_rotation_period}"
    #     retry_duration = "${var.es_retry_duration}"
    #     role_arn = "${aws_iam_role.elasticsearch_delivery_role.arn}"
    #     s3_backup_mode = "${var.es_s3_backup_mode}"
    # }
    
    s3_configuration {
        role_arn = "${aws_iam_role.s3_delivery_role.arn}"
        bucket_arn = "${aws_s3_bucket.s3_logging_bucket.arn}"
        buffer_size = "${var.s3_buffer_size}"
        buffer_interval = "${var.s3_buffer_interval}"
        compression_format = "${var.s3_compression_format}"
        prefix = "${var.s3_prefix}"
        kms_key_arn = "${var.s3_kms_key_arn != "" ? var.s3_kms_key_arn : aws_kms_key.s3_logging_kms_key.arn}"
        cloudwatch_logging_options {
            enabled = "${var.s3_cloudwatch_logging_enabled}"
            log_group_name = "${aws_cloudwatch_log_group.s3_log_group.name}"
            log_stream_name = "${aws_cloudwatch_log_stream.s3_log_stream.name}"
        }
    }
}

# resource "aws_cloudwatch_log_group" "es_log_group" {
#     name = "${var.es_log_group_name}"
#     retention_in_days = "${var.es_log_retention_in_days}"
# }

resource "aws_cloudwatch_log_group" "s3_log_group" {
    name = "${var.s3_log_group_name}"
    retention_in_days = "${var.s3_log_retention_in_days}"
}

# resource "aws_cloudwatch_log_stream" "es_log_stream" {
#     name = "${var.es_log_stream_name}"
#     log_group_name = "${aws_cloudwatch_log_group.es_log_group.name}"
# }

resource "aws_cloudwatch_log_stream" "s3_log_stream" {
    name = "${var.s3_log_stream_name}"
    log_group_name = "${aws_cloudwatch_log_group.s3_log_group.name}"
}

resource "aws_s3_bucket" "s3_logging_bucket" {
  bucket = "${var.s3_logging_bucket_name}"
  acl    = "private"
}

