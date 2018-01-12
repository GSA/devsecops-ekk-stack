variable "s3_logging_bucket_name" {
    type = "string"
}
variable "kinesis_delivery_stream" {
    type = "string"
}
variable "s3_kms_key_arn" {
    type = "string"
    description = "KMS Key ARN used to encrypt data within S3 bucket. The key must already exist within the account."
    default = ""
}
variable "aws_region" {
    default = "us-east-1"
}
# variable "es_domain_name" {
#     default = "devsecops-ekk-stack"
# }
# variable "es_version" {
#     default = "1.5"
# }
# variable "es_instance_type" {
#     default = "t2.micro.elasticsearch"
# }
# variable "es_instance_count" {
#     default = "2"
# }
# variable "es_dedicated_master_instance_type" {
#     default = "t2.micro.elasticsearch"
# }
# variable "es_dedicated_master_count" {
#     default = "2"
# }
# variable "elasticsearch_role_name" {
#     default = "EKKElasticSearchRole"
# }
# variable "elasticsearch_role_policy_name" {
#     default = "EKKElasticSearchRolePolicy"
# }
variable "s3_delivery_role_name" {
    default = "EKKS3DeliveryRole"
}
variable "s3_role_log_bucket_access_policy" {
    default = "S3RoleBucketAccessPolicy"
}
# variable "es_delivery_role_name" {
#     default = "ESDeliveryRole"
# }
# variable "es_log_group_name" {
#     default = "ElasticSearchDeliveryLogGroup"
# }
# variable "es_log_retention_in_days" {
#     default = "7"
# }
# variable "es_log_stream_name" {
#     default = "ElasticSearchDelivery"
# }
variable "s3_log_group_name" {
    default = "S3DeliveryLogGroup"
}
variable "s3_log_retention_in_days" {
    default = "7"
}
variable "s3_log_stream_name" {
    default = "S3Delivery"
}
# variable "es_dedicated_master_enabled" {
#     default = "true"
# }
# variable "es_zone_awareness_enabled" {
#     default = "true"
# }
# variable "es_advanced_allow_explicit_index" {
#     default = "true"
# }
# variable "es_ebs_enabled" {
#     default = "true"
# }
# variable "es_ebs_iops" {
#     default = "0"
# }
# variable "es_ebs_volume_size" {
#     default = "20"
# }
# variable "es_ebs_volume_type" {
#     default = "gp2"
# }
# variable "es_snapshot_start_hour" {
#     default = "0"
# }
# variable "es_buffering_interval" {
#     default = "60"
# }
# variable "es_buffering_size" {
#     default = "50"
# }
# variable "es_cloudwatch_logging_enabled" {
#     default = "true"
# }
# variable "es_index_name" {
#     default = "logmonitor"
# }
# variable "es_type_name" {
#     default = "log"
# }
# variable "es_index_rotation_period" {
#     default = "NoRotation"
# }
# variable "es_retry_duration" {
#     default = "60"
# }
# variable "es_s3_backup_mode" {
#     default = "AllDocuments"
# }
variable "s3_buffer_size" {
    default = "10"
}
variable "s3_buffer_interval" {
    default = "300"
}
variable "s3_compression_format" {
    default = "UNCOMPRESSED"
}
variable "s3_prefix" {
    default = "firehose/"
}
variable "s3_cloudwatch_logging_enabled" {
    default = "true"
}