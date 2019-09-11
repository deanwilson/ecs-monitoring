# AWS ECS monitoring cluster

Prometheus monitoring stack implemented as an AWS ECS learning experiment

## Introduction

This repository is an experiment in running containerised services
on Amazon Elastic Container Service (ECS). It only implements the services
needed to experiment with ECS as a platform, it does not contain many of the
features you'd expect in a full amazon environment, such as enabling CloudTrail.

## Architecture

The general architecture for this implementation is a standard VPC with three
levels of subnets, public, private and database. All ingress is provided by an
external ALB in front of Nginx, which connects to a number of internal services,
some of which use an internal ALB and private route53 zone.

## Set up your environment

This experimental repo assumes you are storing your state in an S3 bucket. Create
and enable versioning on this bucket before you run any other commands.

    export TERRAFORM_BUCKET=deanwilson-ecs-monitoring

    aws s3 mb "s3://${TERRAFORM_BUCKET}"

    aws s3api put-bucket-versioning  \
      --bucket ${TERRAFORM_BUCKET} \
      --versioning-configuration Status=Enabled

Now you have a bucket name you will create the configuration for your
stack. Inside the `environments` directory you will find a pair of files
for each stack, a `.backend` and a `.tfvars`. Make a copy of an existing
pair and change the values to suit your new name. The `bucket`
and `remote_state_bucket` settings in these files must match the bucket you
created above.

## Creating your environment

Once you've created your environment configurations, and added the
correct bucket name, you can create the environment. Each stage of the
environment is separated into a directory inside
[terraform/projects](/terraform/projects) to allow easier changing of
individual aspects of the deployment.

The commands to build each section are the same between components:

    # change to the project directory
    cd terraform/projects/infra-networking

    # Initialise the backend to use our S3 bucket
    $ terraform init -backend-config=../../../environments/dwilson-staging.backend

    # show all the pending actions (most useful when changing terraform code)
    $ terraform plan -var-file=../../../environments/dwilson-staging.tfvars

    # apply the changes to your running system
    $ terraform apply -var-file=../../../environments/dwilson-staging.tfvars

To build a full environment the order is:

 * infra-networking
 * infra-security-groups
 * app-ecs-albs
 * app-ecs-nodes
 * app-ecs-services

## Creating documentation

The projects in this repo use the [terraform-docs](https://github.com/segmentio/terraform-docs)
to generate the per project documentation.

When adding a new project you should run

    terraform-docs markdown . > readme.md

In the project directory and add that to your commit.

## ECS

### Newest ECS AMI

To see the latest ECS Optimised Amazon Linux AMI information in your
default region, run this AWS CLI command:

    aws ssm get-parameters --names /aws/service/ecs/optimized-ami/amazon-linux/recommended

### License

This repo and the code within it are licensed under the GPLv2.

### Author

[Dean Wilson](https://www.unixdaemon.net)
