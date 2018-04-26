# ecs-monitoring

An AWS ECS based monitoring stack - learning repo - not for prod

## Set up your environment

This experimental repo assumes you are storing your state in an S3 bucket. Create
and enable versioning on this bucket before you run any other commands.

    export TERRAFORM_BUCKET=deanwilson-ecs-monitoring

    aws s3 mb "s3://${TERRAFORM_BUCKET}"

    aws s3api put-bucket-versioning  \
      --bucket ${TERRAFORM_BUCKET} \
      --versioning-configuration Status=Enabled

You will currently need to run `sed` over the codebase if you want to
use a different bucket name.

Now you have a bucketname you will create the configurarion for your stack. Inside
the `environments` directory you will find a pair of files for each stack, a `.backend`
and a `.tfvars`. Make a copy of an existing pair and change the values to suit your new name.

## Creating your environment

Once you've created your environment, and tweaked the bucket name
to suit your own bucket you can create the environment with:

    cd terraform/projects/infra-networking

    $ terraform init -backend-config=../../../environments/dwilson-staging.backend

    $ terraform plan -var-file=./../../environments/dwilson-staging.tfvars

    $ terraform apply -var-file=./../../environments/dwilson-staging.tfvars

    cd ../infra-security-groups

    # terraform commands from above

    cd ../app-ecs-nodes

    # terraform commands from above

    cd ../app-ecs-albs

    # terraform commands from above

    cd ../app-ecs-services

    # terraform commands from above

## Creating documentation

The projects in this repo use the [terraform-docs](https://github.com/segmentio/terraform-docs)
to generate the per project documentation.

When adding a new project you should run

    terraform-docs markdown . > index.md

In the project directory and add that to your commit.

## ECS

### Newest ECS AMI

To see the latest ECS Optimized Amazon Linux AMI information in your
default region, run this AWS CLI command:

    aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux/recommended
