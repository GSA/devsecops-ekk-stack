#!/bin/bash
# This user data sets up the test instance to curl the localhost port 80 to generate apache logs. Kinesis should then feed them to the proper stream that was created in Terraform.

# Install necessary packages
yum -y install httpd aws-kinesis-agent

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

cat<<EOF>/root/test.sh
#!/bin/bash
# Test connectivity to localhost port
for i in {1..5900};do curl -s -w "%{time_total}\n" -o /dev/null http://localhost/; done
EOF

# Set cron to run the tests
chmod +x /root/test.sh
echo "* * * * * /root/test.sh" >> /root/mycron
crontab /root/mycron
rm /root/mycron

# Set permissions on httpd directory
service httpd start
chown -R aws-kinesis-agent-user:root /var/log/httpd
chmod -R 764 /var/log/httpd

# Make sure kinesis agent is using the correct agent.json above
service aws-kinesis-agent start