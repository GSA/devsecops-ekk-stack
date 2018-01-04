variable "aws_region" {
    default = "us-east-1"
}
variable "es_domain_name" {
    default = "devsecops-ekk-stack"
}
variable "es_version" {
    default = "1.5"
}
variable "es_instance_type" {
    default = "t2.micro.elasticsearch"
}
variable "es_instance_count" {
    default = "2"
}
variable "es_dedicated_master_instance_type" {
    default = "t2.micro.elasticsearch"
}
variable "es_dedicated_master_count" {
    default = "2"
}
variable "s3_logging_bucket_name" {
    type = "string"
}
variable "elasticsearch_role_name" {
    default = "EKKElasticSearchRole"
}
variable "elasticsearch_role_policy_name" {
    default = "EKKElasticSearchRolePolicy"
}
variable "s3_delivery_role_name" {
    default = "EKKS3DeliveryRole"
}
variable "s3_role_log_bucket_access_policy" {
    default = "S3RoleBucketAccessPolicy"
}
variable "es_delivery_role_name" {
    default = "ESDeliveryRole"
}
variable "es_log_group_name" {
    default = "ElasticSearchDeliveryLogGroup"
}
variable "es_log_retention_in_days" {
    default = "7"
}
variable "es_log_stream_name" {
    default = "ElasticSearchDelivery"
}
variable "s3_log_group_name" {
    default = "S3DeliveryLogGroup"
}
variable "s3_log_retention_in_days" {
    default = "7"
}
variable "s3_log_stream_name" {
    default = "S3Delivery"
}
variable "es_kinesis_delivery_stream" {
}