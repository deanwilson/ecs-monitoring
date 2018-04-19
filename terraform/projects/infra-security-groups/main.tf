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

variable "remote_state_infra_networking_key_stack" {
  type        = "string"
  description = "Override infra-networking remote state path"
  default     = "infra-security-groups.tfstate"
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
    key    = "infra-security-groups.tfstate"
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

## Resources

module "monitoring_external_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.stack_name}-monitoring_external_sg"
  description = "Controls external access to the monitoring instances"
  vpc_id      = "${data.terraform_remote_state.infra_networking.vpc_id}"

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP in from everyone"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "ALL"
      description = "Allow all egress"
      cidr_blocks = "0.0.0.0/0"
    }
  ]


  tags = {
    Terraform   = "true"
    Environment = "testing"
    Owner       = "dwilson"
    Stack       = "${var.stack_name}"
    Project     = "infra-security-groups"
  }
}

module "monitoring_internal_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.stack_name}-monitoring_internal_sg"
  description = "Controls access to the monitoring instances from the LBs"
  vpc_id      = "${data.terraform_remote_state.infra_networking.vpc_id}"

  ingress_with_source_security_group_id = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP in from LBs"
      source_security_group_id = "${module.monitoring_external_sg.this_security_group_id}"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "ALL"
      description = "Allow all egress"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "testing"
    Owner       = "dwilson"
    Stack       = "${var.stack_name}"
    Project     = "infra-security-groups"
  }
}


## Outputs

output "monitoring_external_sg_id" {
  value       = "${module.monitoring_external_sg.this_security_group_id}"
  description = "monitoring_external_sg ID"
}

output "monitoring_internal_sg_id" {
  value       = "${module.monitoring_internal_sg.this_security_group_id}"
  description = "monitoring_internal_sg ID"
}
