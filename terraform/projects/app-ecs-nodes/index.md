## Project: app-ecs-nodes

Create ECS worker nodes



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws_region | AWS region | string | `eu-west-1` | no |
| remote_state_bucket | S3 bucket we store our terraform state in | string | `deanwilson-ecs-monitoring` | no |
| remote_state_infra_networking_key_stack | Override infra-networking remote state path | string | `infra-security-groups.tfstate` | no |
| stack_name | Unique name for this collection of resources | string | `dwilson-ecs-monitoring` | no |

## Outputs

| Name | Description |
|------|-------------|
| ecs-node-1_asg_id | ecs-node-1 ASG ID |

