output "es_domain_arn" {
    value = "${aws_elasticsearch_domain.elasticsearch.arn}"
}

output "es_domain_endpoint" {
    value = "${aws_elasticsearch_domain.elasticsearch.endpoint}"
}
