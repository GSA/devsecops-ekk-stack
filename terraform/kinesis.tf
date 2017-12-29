resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
    name = "${var.es_kinesis_delivery_stream}"
    destination = "elasticsearch"
    
    elasticsearch_configuration {
        buffering_interval = 60
        buffering_size = 50
        cloudwatch_logging_options {
            enabled = "true"
            log_group_name = "${aws_cloudwatch_log_group.es_log_group.name}"
            log_stream_name = "${aws_cloudwatch_log_stream.es_log_stream.name}"
        }
        domain_arn = "${aws_elasticsearch_domain.elasticsearch.arn}"
        role_arn = "${aws_iam_role.elasticsearch_delivery_role.arn}"
        index_name = "logmonitor"
        type_name = "log"
        index_rotation_period = "NoRotation"
        retry_duration = "60"
        role_arn = "${aws_iam_role.elasticsearch_delivery_role.arn}"
        s3_backup_mode = "AllDocuments"
    }
    
    s3_configuration {
        role_arn = "${aws_iam_role.s3_delivery_role.arn}"
        bucket_arn = "${aws_s3_bucket.s3_logging_bucket.arn}"
        buffer_size = 10
        buffer_interval = 300
        compression_format = "UNCOMPRESSED"
        prefix = "firehose/"
        cloudwatch_logging_options {
            enabled = "true"
            log_group_name = "${aws_cloudwatch_log_group.s3_log_group.name}"
            log_stream_name = "${aws_cloudwatch_log_stream.s3_log_stream.name}"
        }
    }
}