variable "s3_logging_bucket_name" {
    type = "string"
}
variable "ec_test_instance_key_name" {
    type = "string"
}
variable "kinesis_delivery_stream" {
    default = "DevSecOpsKinesisDeliveryStream"
}
variable "ekk_kinesis_stream_name" {
    default = "DevSecOpsKinesisStream"
}