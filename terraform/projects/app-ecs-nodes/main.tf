/**
* ## Project: app-ecs-nodes
*
* Create ECS worker nodes
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
    key    = "app-ecs-nodes.tfstate"
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

module "ecs-node-1" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "${var.stack_name}-ecs-node-1-"

  key_name = "dwilson-test" # TODO - Param

  # Launch configuration
  lc_name = "${var.stack_name}-ecs-node-1-"

  image_id        = "ami-2d386654" # TODO - Param
  instance_type   = "t2.micro" # TODO - Param
  security_groups = ["${data.terraform_remote_state.infra_security_groups.monitoring_internal_sg_id}"]
  #iam_instance_profile = "ecs-node-policy"
  iam_instance_profile = "${var.stack_name}-ecs-profile"

  root_block_device = [
    {
      volume_size = "50" # TODO - Param
      volume_type = "gp2"
    },
  ]

  user_data = <<EOF
#!/bin/bash
# Set any ECS agent configuration options
yum install -y ecs-init
start ecs
service docker start

#echo 'ECS_CLUSTER=dwilson-ecs-monitoring' >> /etc/ecs/ecs.config
echo 'ECS_CLUSTER=default' >> /etc/ecs/ecs.config
EOF

  # Auto scaling group
  asg_name                  = "${var.stack_name}-ecs-node-1-"
  vpc_zone_identifier       = ["${element(data.terraform_remote_state.infra_networking.private_subnets, 1)}"]
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Terraform"
      value               = "true"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "app-ecs-nodes"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = "testing"
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = "dwilson"
      propagate_at_launch = true
    },
    {
      key                 = "Stack"
      value               = "${var.stack_name}"
      propagate_at_launch = true
    },

  ]

}

## Outputs

output "ecs-node-1_asg_id" {
  value       = "${module.ecs-node-1.this_autoscaling_group_id}"
  description = "ecs-node-1 ASG ID"
}

