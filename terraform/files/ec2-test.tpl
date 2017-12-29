#!/bin/bash

# Install necessary packages
yum -y install httpd aws-kinesis-agent
service aws-kinesis-agent start
service httpd start

# Create necessary test files
cat<<EOF>/etc/aws-kinesis/agent.json
{
    "cloudwatch.emitMetrics": true,
    "firehose.endpoint": "firehose.us-east-1.amazonaws.com",
    "flows": [
        {
            "filePattern": "/var/log/httpd/access_log",
            "deliveryStream": "${deliverystream}",
            "dataProcessingOptions": [
                {
                    "optionName": "LOGTOJSON",
                    "logFormat": "COMMONAPACHELOG"
                }
            ]
        }
    ]
}
EOF

# Test connectivity to localhost port
for i in {1..1000};do curl -s -w "%{time_total}\n" -o /dev/null http://localhost/; done
