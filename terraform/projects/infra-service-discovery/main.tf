/**
* ## Project: infra-service-discovery
*
* Service discovery
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

# locals
# --------------------------------------------------------------

# Resources
# --------------------------------------------------------------

## Providers

terraform {
  required_version = "= 0.11.7"

  backend "s3" {
    key = "infra-service-discovery.tfstate"
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

resource "aws_service_discovery_private_dns_namespace" "prometheus" {
  name        = "sd.ecs-monitoring.com"
  description = "ECS Monitoring service discovery zone"
  vpc         = "${data.terraform_remote_state.infra_networking.vpc_id}"
}

# TODO: move these resources to the app-ecs-services project
resource "aws_service_discovery_service" "prometheus_server" {
  name = "prometheus-server"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.prometheus.id}"

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

# TODO: move these resources to the app-ecs-services project
resource "aws_service_discovery_service" "prometheus_blackbox" {
  name = "prometheus-blackbox"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.prometheus.id}"

    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}

<<<<<<< HEAD
=======
# TODO: move these resources to the app-ecs-services project
resource "aws_service_discovery_service" "metrics_nginx" {
  name = "metrics-nginx"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.prometheus.id}"
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
}



>>>>>>> 18254e9... Extract the metrics nginx and add a service record for it
## Outputs

output "prometheus_server_discovery_arn" {
  value       = "${aws_service_discovery_service.prometheus_server.arn}"
  description = "Prometheus server service discovery ARN"
}

output "prometheus_blackbox_discovery_arn" {
  value       = "${aws_service_discovery_service.prometheus_blackbox.arn}"
  description = "Prometheus server service discovery ARN"
}

output "metrics_nginx_discovery_arn" {
  value       = "${aws_service_discovery_service.metrics_nginx.arn}"
  description = "Metrics Nginx server service discovery ARN"
}
