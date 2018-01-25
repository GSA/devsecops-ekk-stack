resource "aws_kinesis_stream" "ekk_kinesis_stream" {
    name = "${var.ekk_kinesis_stream_name}"
    shard_count = "${var.ekk_kinesis_stream_shard_count}"
    retention_period = "${var.ekk_kinesis_stream_retention_period}"

    shard_level_metrics = "${var.ekk_kinesis_stream_shard_metrics}"

    encryption_type = "KMS"
    # Strangely, this uses the KMS GUID instead of the ARN
    # kms_key_id = "${var.ekk_kinesis_stream_kms_key_id}"
    kms_key_id = "${var.ekk_kinesis_stream_kms_key_id != "" ? var.ekk_kinesis_stream_kms_key_id : aws_kms_key.kinesis_stream_kms_key.key_id}"
}

resource "aws_kinesis_firehose_delivery_stream" "ekk_kinesis_delivery_stream" {
    name = "${var.kinesis_delivery_stream}"
    destination = "s3"
    kinesis_source_configuration = {
        kinesis_stream_arn = "${aws_kinesis_stream.ekk_kinesis_stream.arn}",
        role_arn = "${aws_iam_role.ekk_role.arn}"
    } 
    
    destination = "elasticsearch"
    
    elasticsearch_configuration {
        buffering_interval = "${var.es_buffering_interval}"
        buffering_size = "${var.es_buffering_size}"
        cloudwatch_logging_options {
            enabled = "${var.es_cloudwatch_logging_enabled}"
            log_group_name = "${aws_cloudwatch_log_group.es_log_group.name}"
            log_stream_name = "${aws_cloudwatch_log_stream.es_log_stream.name}"
        }
        domain_arn = "${aws_elasticsearch_domain.elasticsearch.arn}"
        role_arn = "${aws_iam_role.ekk_role.arn}"
        index_name = "${var.es_index_name}"
        type_name = "${var.es_type_name}"
        index_rotation_period = "${var.es_index_rotation_period}"
        retry_duration = "${var.es_retry_duration}"
        role_arn = "${aws_iam_role.ekk_role.arn}"
        s3_backup_mode = "${var.es_s3_backup_mode}"
    }
    
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