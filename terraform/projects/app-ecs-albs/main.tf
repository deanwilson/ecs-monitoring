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
    key    = "app-ecs-albs.tfstate"
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

## Resources

resource "aws_lb" "monitoring_external_alb" {
  name               = "${var.stack_name}-ext-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${data.terraform_remote_state.infra_security_groups.monitoring_external_sg_id}"]
  subnets            = [
    "${element(data.terraform_remote_state.infra_networking.public_subnets, 1)}",
    "${element(data.terraform_remote_state.infra_networking.public_subnets, 2)}"
  ]

  ## TODO Add access logs back in later
  /* access_logs { */
  /*   bucket  = "${aws_s3_bucket.lb_logs.bucket}" */
  /*   prefix  = "test-lb" */
  /*   enabled = true */
  /* } */

  tags = {
    Terraform   = "true"
    Environment = "testing"
    Owner       = "dwilson"
    Stack       = "${var.stack_name}"
  }
}

resource "aws_lb_target_group" "monitoring_external_tg" {
  name     = "${var.stack_name}-ext-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.infra_networking.vpc_id}"
  # TODO Add health check on

  health_check {
    interval            = "10"
    path                = "/"
    matcher             = "200"
    port                = "80"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = "6"
  }
}


resource "aws_lb_listener" "monitoring_external" {
  load_balancer_arn = "${aws_lb.monitoring_external_alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.monitoring_external_tg.arn}"
    type             = "forward"
  }
}



## Outputs

