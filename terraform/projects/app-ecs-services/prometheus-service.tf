resource "aws_ecs_task_definition" "prometheus_server" {
  family                = "prometheus-server"
  network_mode          = "awsvpc"
  container_definitions = "${file("task-definitions/prometheus-server.json")}"

  volume {
    name      = "prometheus-config"
    host_path = "/ecs/pulled-config/prometheus/prometheus.yml"
  }

  volume {
    name      = "alert-config"
    host_path = "/ecs/pulled-config/prometheus/alerts/alerts.default"
  }
}

resource "aws_ecs_service" "prometheus_server" {
  name            = "prometheus-server"
  cluster         = "${local.cluster_name}"
  task_definition = "${aws_ecs_task_definition.prometheus_server.arn}"
  desired_count   = 1

  service_registries {
    registry_arn = "${data.terraform_remote_state.infra_service_discovery.prometheus_server_discovery_arn}"
  }

  network_configuration {
    subnets = ["${data.terraform_remote_state.infra_networking.private_subnets}"]
  }
}
