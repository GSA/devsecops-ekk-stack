# devsecops-ekk-stack

Terraform that builds an EKK logging stack.

This stack is based on [this CloudFormation example.](https://us-west-2.console.aws.amazon.com/cloudformation/designer/home?region=us-west-2&templateUrl=https://s3.amazonaws.com/scriptdepot/es.template)

The stack also creates a small EC2 instance (defined in ec2-test.tf) that will be configured with a kinesis agent to test writing into the stream. If you do not wish to deploy this instance, move this file out of the terraform directory or change the extension of the file.

## Deployment

1. Create an S3 bucket for the terraform state.
1. Run the following command:

    ````sh
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
