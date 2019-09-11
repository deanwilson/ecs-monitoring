## Project: infra-networking

Terraform project to deploy the networking required for a VPC and
related services. You will often have multiple VPCs in an account.

Also provides the private Route53 zone used for internal service
communication.



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_tags | Stack specific tags to apply | map | `<map>` | no |
| aws_region | AWS region | string | `eu-west-1` | no |
| stack_name | Unique name for this collection of resources | string | `ecs-monitoring` | no |
| zone_name | Private zone name for internal communication | string | `sd.ecs-monitoring.com` | no |

## Outputs

| Name | Description |
|------|-------------|
| private_monitoring_domain_name | Domain name used for the private Route53 zone |
| private_monitoring_zone_id | Private monitoring Route53 zone ID |
| private_subnets | List of private subnet IDs |
| public_subnets | List of public subnet IDs |
| vpc_id | VPC ID where the stack resources are created |

