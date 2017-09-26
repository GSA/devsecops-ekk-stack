resource "aws_elasticsearch_domain" "elasticsearch" {
  domain_name = "${var.es_domain_name}"
  elasticsearch_version = "${var.es_version}
  
  cluster_config {
      dedicated_master_enabled = "true"
      instance_type = "${var.es_instance_type}"
      instance_count = "${var.es_instance_count}"
      zone_awareness_enabled = "true"
      dedicated_master_type = "${var.es_dedicated_master_instance_type}"
      dedicated_master_count = "${var.es_dedicated_master_count}"
  }

  advanced_options {
      "rest.action.multi.allow_explicit_index" = "true"
  }

  ebs_options {
      ebs_enabled = "true"
      iops = "0"
      volume_size = "20"
      volume_type = "gp2"
  }

  snapshot_options {
      automated_snapshot_start_hour = 0
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