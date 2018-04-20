## Project: app-ecs-albs

Create ALBs for the ECS cluster

This may be merged back in to the nodes project



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws_region | AWS region | string | `eu-west-1` | no |
| remote_state_bucket | S3 bucket we store our terraform state in | string | `deanwilson-ecs-monitoring` | no |
| stack_name | Unique name for this collection of resources | string | `dwilson-ecs-monitoring` | no |

