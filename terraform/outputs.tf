output "es_domain_arn" {
    value = "${aws_elasticsearch_domain.elasticsearch.es_domain_arn}"
}

output "es_domain_url" {
    value = "${aws_elasticsearch_domain.elasticsearch.es_domain_url}"
}

output "kinesis_firehose_delivery_name" {
    value = "${blah3}"
}