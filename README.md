# devsecops-ekk-stack

Terraform that builds an EKK logging stack.

This stack is based on [this CloudFormation example.](https://us-west-2.console.aws.amazon.com/cloudformation/designer/home?region=us-west-2&templateUrl=https://s3.amazonaws.com/scriptdepot/es.template)

The stack also creates a small EC2 instance (defined in ec2-test.tf) that will be configured with a kinesis agent to test writing into the stream. If you do not wish to deploy this instance, move this file out of the terraform directory or change the extension of the file.

## Usage

This stack is meant to be consumed as a module in your existing terraform stack. You can consume it by using code similar to this:

```hcl
module "ekk_stack" {
    source = "github.com/GSA/devsecops-ekk-stack//terraform"
    s3_logging_bucket_name = "${var.s3_logging_bucket_name}"
    kinesis_delivery_stream = "${var.kinesis_delivery_stream}"
    ekk_kinesis_stream_name = "${var.ekk_kinesis_stream_name}"
}
```

...where the variables referenced above are defined in your terraform.tfvars file. "var.s3_logging_bucket_name" should be set to a bucket (which the stack will create) to contain copies of the kinesis firehose logs. "var.kinesis_delivery_stream" should be set to the name of the firehose delivery stream that you wish to use. The EKK stack will create this delivery stream with the name you provide with this variable.

The Kinesis stream will send to Elasticsearch and S3.

## Test Deployment

Use these steps to deploy the test.

1. Create an S3 bucket for the terraform state.
1. Run the following command:

    ````sh
    cd terraform/test
    cp backend.tfvars.example backend.tfvars
    cp terraform.tfvars.example terraform.tfvars
    ````

1. Fill out backend.tfvars with the name of the S3 bucket you just created.
1. Fill out terraform.tfvars with required values.
1. Run the init:

    ````sh
    terraform init --backend-config="backend.tfvars"
    ````

1. Run a plan to make sure everything is fine and ready to go:

    ````sh
    terraform plan
    ````

1. If there are no issues, apply the stack:

    ````sh
    terraform apply
    ````
Following the steps above will emulate the intended behavior of the stack. You must execute it from the test directory just below the terraform directory. The test consumes the stack as a module and deploys it, then sets up an EC2 instance that will install the aws-kinesis-agent and configure it to stream to the Kinesis Firehose delivery stream.

The EC2 instance also configures itself with a cron job that performs a curl against its local apache2 daemon 5900 times every minute. This is used to generate logs that the Kinesis agent will capture. To verify that it is working properly, you can login to the EC2 instance and tail the aws-kinesis agent log (/var/log/aws-kinesis/aws-kinesis-agent.log) or look in the web console at the CloudWatch metrics for the Firehose delivery stream itself.
