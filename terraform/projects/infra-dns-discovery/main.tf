/**
* ## Project: infra-dns-discovery
*
* Manage the common DNS infrastructure to enable basic DNS discovery
* and communicaiton between services
*
* TODO: once everything is working decide if this should be isolated
* or in ALB / networking projects instead
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

variable "zone_name" {
  type        = "string"
  description = "Private zone name for internal communication"
  default     = "sd.ecs-monitoring.com"
}

# locals
# --------------------------------------------------------------

locals {
  default_tags = {
    Terraform = "true"
    Project   = "infra-dns-discovery"
  }
}

# Resources
# --------------------------------------------------------------

## Providers

terraform {
  required_version = "= 0.11.7"

  backend "s3" {
    key = "infra-dns-discovery.tfstate"
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

resource "aws_route53_zone" "private_monitoring" {
  name = "${var.zone_name}"

  comment = "Terraform managed private zone for service communication"
  vpc_id  = "${data.terraform_remote_state.infra_networking.vpc_id}"

  tags = "${merge(
    local.default_tags,
    var.additional_tags,
    map("Stackname", "${var.stack_name}"),
    map("Name", "${var.stack_name}-ecs-monitoring-private")
  )}"
}

## Outputs

output "private_monitoring_zone_id" {
  value       = "${aws_route53_zone.private_monitoring.zone_id}"
  description = "Private monitoring Route53 zone ID"
}

output "private_monitoring_domain_name" {
  value       = "${var.zone_name}"
  description = "Domain name used for the private Route53 zone"
}
