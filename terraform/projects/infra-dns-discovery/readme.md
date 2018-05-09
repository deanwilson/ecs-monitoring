## Project: infra-dns-discovery

Manage the common DNS infrastructure to enable basic DNS discovery
and communicaiton between services

TODO: once everything is working decide if this should be isolated
or in ALB / networking projects instead



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_tags | Stack specific tags to apply | map | `<map>` | no |
| aws_region | AWS region | string | `eu-west-1` | no |
| remote_state_bucket | S3 bucket we store our terraform state in | string | `ecs-monitoring` | no |
| remote_state_infra_networking_key_stack | Override infra-networking remote state path | string | `infra-security-groups.tfstate` | no |
| stack_name | Unique name for this collection of resources | string | `ecs-monitoring` | no |
| zone_name | Private zone name for internal communication | string | `sd.ecs-monitoring.com` | no |

## Outputs

| Name | Description |
|------|-------------|
| private_monitoring_domain_name | Domain name used for the private Route53 zone |
| private_monitoring_zone_id | Private monitoring Route53 zone ID |

