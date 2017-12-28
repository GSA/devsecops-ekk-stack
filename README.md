# devsecops-ekk-stack

Terraform that builds an EKK logging stack.

This stack is based on [this CloudFormation example.](https://us-west-2.console.aws.amazon.com/cloudformation/designer/home?region=us-west-2&templateUrl=https://s3.amazonaws.com/scriptdepot/es.template)

It currently does NOT introduce any demonstration data.

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
