# ecs-monitoring

An AWS ECS based monitoring stack - learning repo - not for prod

## Set up your environment

This experiment repo assumes you are storing your state in an S3 bucket. Create
an enable versioning on this bucket before you run any other commands.

    export TERRAFORM_BUCKET=deanwilson-ecs-monitoring

    aws s3 mb "s3://${TERRAFORM_BUCKET}"

    aws s3api put-bucket-versioning  \
      --bucket ${TERRAFORM_BUCKET} \
      --versioning-configuration Status=Enabled

You will currently need to run `sed` over the codebase if you want to
use a different bucket name.

## Creating your environment

Once you've created your environment, and tweaked the bucket name
to suit your own bucket you can create the environment with:

    cd terraform/projects/infra-networking

    $ terraform init -backend-config=../../../environments/dwilson-staging.backend

    $ terraform plan

    $ terraform apply

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
