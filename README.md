# devsecops-ekk-stack

Terraform that builds an EKK logging stack.

This stack is based on [this CloudFormation example.](https://us-west-2.console.aws.amazon.com/cloudformation/designer/home?region=us-west-2&templateUrl=https://s3.amazonaws.com/scriptdepot/es.template)

The stack also creates a small EC2 instance (defined in ec2-test.tf) that will be configured with a kinesis agent to test writing into the stream. If you do not wish to deploy this instance, move this file out of the terraform directory or change the extension of the file.

## Deployment

This stack is meant to be consumed as a module in your existing terraform stack. You can consume it by using code similar to this:

    ````
    module "ekk_stack" {
        source = "github.com/GSA/devsecops-ekk-stack"
        s3_logging_bucket_name = "${var.s3_logging_bucket_name}"
        es_kinesis_delivery_stream = "${var.es_kinesis_delivery_stream}"
    }
    ````

...where the variables referenced above are defined in your terraform.tfvars file.

Following the steps below will emulate this exact behavior. You must execute it from the test directory just below the terraform directory. The test consumes the stack as a module and deploys it, then sets up an EC2 instance that will install the aws-kinesis-agent and configure it to stream to the Kinesis Firehose delivery stream.

The Kinesis stream will send to Elasticsearch and S3.

The EC2 instance also configures itself with a cron job that performs a curl against its local apache2 daemon 5900 times every minute. This is used to generate logs that the Kinesis agent will capture. To verify that it is working properly, you can login to the EC2 instance and tail the aws-kinesis agent log (/var/log/aws-kinesis/aws-kinesis-agent.log) or look in the web console at the CloudWatch metrics for the Firehose delivery stream itself.

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
