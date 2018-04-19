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

    $ terraform init

    $ terraform plan

    $ terraform apply
