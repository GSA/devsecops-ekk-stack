resource "aws_elasticsearch_domain" "elasticsearch" {
  domain_name           = "${var.es_domain_name}"
  elasticsearch_version = "${var.es_version}"

  cluster_config {
    dedicated_master_enabled = "${var.es_dedicated_master_enabled}"
    instance_type            = "${var.es_instance_type}"
    instance_count           = "${var.es_instance_count}"
    zone_awareness_enabled   = "${var.es_zone_awareness_enabled}"
    dedicated_master_type    = "${var.es_dedicated_master_instance_type}"
    dedicated_master_count   = "${var.es_dedicated_master_count}"
  }

  advanced_options {
    "rest.action.multi.allow_explicit_index" = "${var.es_advanced_allow_explicit_index}"
  }

  ebs_options {
    ebs_enabled = "${var.es_ebs_enabled}"
    iops        = "${var.es_ebs_iops}"
    volume_size = "${var.es_ebs_volume_size}"
    volume_type = "${var.es_ebs_volume_type}"
  }

  encrypt_at_rest {
    enabled    = "true"
    kms_key_id = "${var.es_kms_key_id != "" ? var.es_kms_key_id : aws_kms_key.es_kms_key.key_id}"
  }

  snapshot_options {
    automated_snapshot_start_hour = "${var.es_snapshot_start_hour}"
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
CONFIG
}
