
resource "aws_ecs_task_definition" "metrics_nginx" {
  family                = "nginx"
  network_mode          = "awsvpc"
  container_definitions = "${file("task-definitions/metrics-nginx.json")}"

  volume {
    name      = "metrics-nginx"
    host_path = "/ecs/pulled-config/nginx-metrics-proxy/metrics-proxy"
  }

}

resource "aws_ecs_service" "metrics_nginx" {
  name            = "metrics_nginx"
  cluster         = "${local.cluster_name}"
  task_definition = "${aws_ecs_task_definition.metrics_nginx.arn}"
  desired_count   = 1

  service_registries {
    registry_arn = "${data.terraform_remote_state.infra_service_discovery.metrics_nginx_discovery_arn}"
  }

  network_configuration {
    subnets = ["${data.terraform_remote_state.infra_networking.private_subnets}"]
  }

}
