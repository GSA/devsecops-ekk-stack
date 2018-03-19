resource "aws_cloudwatch_log_group" "es_log_group" {
    name = "${var.es_log_group_name}"
    retention_in_days = "${var.es_log_retention_in_days}"
}

resource "aws_cloudwatch_log_group" "s3_log_group" {
    name = "${var.s3_log_group_name}"
    retention_in_days = "${var.s3_log_retention_in_days}"
}

resource "aws_cloudwatch_log_stream" "es_log_stream" {
    name = "${var.es_log_stream_name}"
    log_group_name = "${aws_cloudwatch_log_group.es_log_group.name}"
}

resource "aws_cloudwatch_log_stream" "s3_log_stream" {
    name = "${var.s3_log_stream_name}"
    log_group_name = "${aws_cloudwatch_log_group.s3_log_group.name}"
}