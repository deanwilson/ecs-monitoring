/**
* ## Project: app-ecs-albs
*
* Create ALBs for the ECS cluster
*
* This may be merged back in to the nodes project
*
*/

variable "aws_region" {
  type        = "string"
  description = "AWS region"
  default     = "eu-west-1"
}

variable "remote_state_bucket" {
  type        = "string"
  description = "S3 bucket we store our terraform state in"
  default     = "deanwilson-ecs-monitoring"
}

variable "stack_name" {
  type        = "string"
  description = "Unique name for this collection of resources"
  default     = "dwilson-ecs-monitoring"
}

# Resources
# --------------------------------------------------------------

## Providers

terraform {
  required_version = "= 0.11.7"

  backend "s3" {
    bucket = "deanwilson-ecs-monitoring"
    key    = "app-ecs-services.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  version = "~> 1.14.1"
  region  = "${var.aws_region}"
}

## Data sources

data "terraform_remote_state" "infra_networking" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket}"
    key    = "infra-networking.tfstate"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "infra_security_groups" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket}"
    key    = "infra-security-groups.tfstate"
    region = "${var.aws_region}"
  }
}

data "terraform_remote_state" "app_ecs_albs" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket}"
    key    = "app-ecs-albs.tfstate"
    region = "${var.aws_region}"
  }
}


## Resources

resource "aws_ecs_task_definition" "base_nginx" {
  family                = "service"
  container_definitions = "${file("task-definitions/base-nginx.json")}"
}

resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = "default"
  task_definition = "${aws_ecs_task_definition.base_nginx.arn}"
  desired_count   = 1
#  iam_role        = "${aws_iam_role.foo.arn}" # TODO
#  depends_on      = ["aws_iam_role_policy.foo"] # TODO as above

  load_balancer {
    target_group_arn = "${data.terraform_remote_state.app_ecs_albs.monitoring_external_tg}"
    container_name   = "nginx"
    container_port   = 80
  }

  /* placement_constraints { */
  /*   type       = "memberOf" */
  /*   expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]" */
  /* } */
}

## Outputs

