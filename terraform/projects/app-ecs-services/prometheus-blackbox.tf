resource "aws_ecs_task_definition" "prometheus_blackbox" {
  family                = "prometheus-blackbox"
  network_mode          = "awsvpc"
  container_definitions = "${file("task-definitions/prometheus-blackbox.json")}"
}

resource "aws_ecs_service" "prometheus_blackbox" {
  name            = "prometheus-blackbox"
  cluster         = "${local.cluster_name}"
  task_definition = "${aws_ecs_task_definition.prometheus_blackbox.arn}"
  desired_count   = 1

  service_registries {
    registry_arn = "${data.terraform_remote_state.infra_service_discovery.service_discovery_arn}"
  }

  network_configuration {
    subnets = ["${data.terraform_remote_state.infra_networking.private_subnets}"]
  }
}
