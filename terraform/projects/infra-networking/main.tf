/**
* ## Project: infra-networking
*
* Terraform project to deploy the networking required for a VPC and
* related services. You will often have multiple VPCs in an account.
*
* Also provides the private Route53 zone used for internal service
* communication.
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
    Project   = "infra-networking"
  }
}

# Resources
# --------------------------------------------------------------

## Providers

terraform {
  required_version = "= 0.11.7"

  backend "s3" {
    key = "infra-networking.tfstate"
  }
}

provider "aws" {
  version = "~> 1.17.0"
  region  = "${var.aws_region}"
}

## Data sources

data "aws_availability_zones" "available" {}

## Resources

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.stack_name}"
  cidr = "10.0.0.0/16"

  # assumes 3 AZs
  azs              = "${data.aws_availability_zones.available.names}"
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]

  enable_nat_gateway   = true
  enable_dns_hostnames = true

  tags = "${merge(
    local.default_tags,
    var.additional_tags,
    map("Stackname", var.stack_name)
  )}"
}

resource "aws_route53_zone" "private_monitoring" {
  name = "${var.zone_name}"

  comment = "Terraform managed private zone for service communication"
  vpc_id  = "${module.vpc.vpc_id}"

  tags = "${merge(
    local.default_tags,
    var.additional_tags,
    map("Stackname", "${var.stack_name}"),
    map("Name", "${var.stack_name}-ecs-monitoring-private")
  )}"
}

## Outputs

output "private_monitoring_domain_name" {
  value       = "${var.zone_name}"
  description = "Domain name used for the private Route53 zone"
}

output "private_monitoring_zone_id" {
  value       = "${aws_route53_zone.private_monitoring.zone_id}"
  description = "Private monitoring Route53 zone ID"
}

output "private_subnets" {
  value       = "${module.vpc.private_subnets}"
  description = "List of private subnet IDs"
}

output "public_subnets" {
  value       = "${module.vpc.public_subnets}"
  description = "List of public subnet IDs"
}

output "vpc_id" {
  value       = "${module.vpc.vpc_id}"
  description = "VPC ID where the stack resources are created"
}
