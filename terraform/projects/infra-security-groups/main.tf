/**
* ## Project: infra-security-groups
*
* Central project to manage all security groups.
*
* This is done in a single project to reduce conflicts
* and cascade issues.
*
*
*/

variable "additional_tags" {
  type        = "map"
  description = "Stack specific tags to apply"
  default     = {}
}

variable "aws_region" {
  type        = "string"
  description = "AWS region"
  default     = "eu-west-1"
}

variable "remote_state_bucket" {
  type        = "string"
  description = "S3 bucket we store our terraform state in"
  default     = "ecs-monitoring"
}

variable "remote_state_infra_networking_key_stack" {
  type        = "string"
  description = "Override infra-networking remote state path"
  default     = "infra-security-groups.tfstate"
}

variable "stack_name" {
  type        = "string"
  description = "Unique name for this collection of resources"
  default     = "ecs-monitoring"
}

locals {
  default_tags = {
    Terraform = "true"
    Project   = "infra-security-groups"
  }
}

# Resources
# --------------------------------------------------------------

## Providers

terraform {
  required_version = "= 0.11.7"

  backend "s3" {
    key = "infra-security-groups.tfstate"
  }
}

provider "aws" {
  version = "~> 1.17.0"
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

## Resources

### External ALB SG

resource "aws_security_group" "monitoring_ext_alb_sg" {
  name        = "${var.stack_name}-monitoring_ext_alb_sg"
  vpc_id      = "${data.terraform_remote_state.infra_networking.vpc_id}"
  description = "Controls external access to the monitoring instances"

  tags = "${merge(
    local.default_tags,
    var.additional_tags,
    map("Stackname", "${var.stack_name}"),
    map("Name", "${var.stack_name}-monitoring_ext_alb_sg")
  )}"
}

resource "aws_security_group_rule" "monitoring_ext_alb_sg_ingress_any_http" {
  type              = "ingress"
  to_port           = 80
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.monitoring_ext_alb_sg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "monitoring_ext_alb_sg_egress_any_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.monitoring_ext_alb_sg.id}"
}

### Internal ALB SG

resource "aws_security_group" "monitoring_int_alb_sg" {
  name        = "${var.stack_name}-monitoring_int_alb_sg"
  vpc_id      = "${data.terraform_remote_state.infra_networking.vpc_id}"
  description = "Controls access to the internal services via the internal ALB"

  tags = "${merge(
    local.default_tags,
    var.additional_tags,
    map("Stackname", "${var.stack_name}"),
    map("Name", "${var.stack_name}-monitoring_int_alb_sg")
  )}"
}

resource "aws_security_group_rule" "monitoring_int_alb_sg_ingress_int-alb_prometheus" {
  type      = "ingress"
  from_port = 9090
  to_port   = 9090
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.monitoring_int_alb_sg.id}"
  source_security_group_id = "${aws_security_group.monitoring_internal_sg.id}"

  description = "Nginx auth container to load balanced prometheus"
}

resource "aws_security_group_rule" "monitoring_int_alb_sg_ingress_int-alb_prometheus-blackbox" {
  type      = "ingress"
  from_port = 9115
  to_port   = 9115
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.monitoring_int_alb_sg.id}"
  source_security_group_id = "${aws_security_group.monitoring_internal_sg.id}"

  description = "ALB ingress for load balanced prometheus blackbox"
}

resource "aws_security_group_rule" "monitoring_int_alb_sg_ingress_int-alb_grafana" {
  type      = "ingress"
  from_port = 3000
  to_port   = 3000
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.monitoring_int_alb_sg.id}"
  source_security_group_id = "${aws_security_group.monitoring_internal_sg.id}"

  description = "ALB ingress for load balanced prometheus blackbox"
}

resource "aws_security_group_rule" "monitoring_int_alb_sg_egress_any_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.monitoring_int_alb_sg.id}"
}

### Internal ECS Node SG

resource "aws_security_group" "monitoring_internal_sg" {
  name        = "${var.stack_name}-monitoring_internal_sg"
  vpc_id      = "${data.terraform_remote_state.infra_networking.vpc_id}"
  description = "Controls access to the monitoring instances from the LBs"

  tags = "${merge(
    local.default_tags,
    var.additional_tags,
    map("Stackname", "${var.stack_name}"),
    map("Name", "${var.stack_name}-monitoring_internal_sg")
  )}"
}

resource "aws_security_group_rule" "monitoring_internal_sg_ingress_alb_http" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.monitoring_internal_sg.id}"
  source_security_group_id = "${aws_security_group.monitoring_ext_alb_sg.id}"
}

resource "aws_security_group_rule" "monitoring_internal_sg_ingress_int-alb_prometheus" {
  type      = "ingress"
  from_port = 9090
  to_port   = 9090
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.monitoring_internal_sg.id}"
  source_security_group_id = "${aws_security_group.monitoring_int_alb_sg.id}"

  description = "Nginx auth container to load balance prometheus"
}

resource "aws_security_group_rule" "monitoring_internal_sg_ingress_loopback_alertmanager" {
  type      = "ingress"
  from_port = 9093
  to_port   = 9093
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.monitoring_internal_sg.id}"
  source_security_group_id = "${aws_security_group.monitoring_internal_sg.id}"

  description = "ECS instances can connect to themselves to access AlertManager"
}

resource "aws_security_group_rule" "monitoring_internal_sg_ingress_int-alb_prometheus-blackbox" {
  type      = "ingress"
  from_port = 9115
  to_port   = 9115
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.monitoring_internal_sg.id}"
  source_security_group_id = "${aws_security_group.monitoring_int_alb_sg.id}"

  description = "Internal ALB to blackbox"
}

resource "aws_security_group_rule" "monitoring_internal_sg_ingress_int-alb_prometheus-grafana" {
  type      = "ingress"
  from_port = 3000
  to_port   = 3000
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.monitoring_internal_sg.id}"
  source_security_group_id = "${aws_security_group.monitoring_int_alb_sg.id}"

  description = "Internal ALB to blackbox"
}


resource "aws_security_group_rule" "monitoring_internal_sg_egress_any_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.monitoring_internal_sg.id}"
}

## Outputs

output "monitoring_ext_alb_sg_id" {
  value       = "${aws_security_group.monitoring_ext_alb_sg.id}"
  description = "monitoring_ext_alb_sg ID"
}

output "monitoring_int_alb_sg_id" {
  value       = "${aws_security_group.monitoring_int_alb_sg.id}"
  description = "monitoring_int_alb_sg ID"
}

output "monitoring_internal_sg_id" {
  value       = "${aws_security_group.monitoring_internal_sg.id}"
  description = "monitoring_internal_sg ID"
}
