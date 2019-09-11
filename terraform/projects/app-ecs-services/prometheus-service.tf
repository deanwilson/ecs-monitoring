data "template_file" "prometheus_server_container_definition" {
  template = "${file("task-definitions/prometheus-server.json.tpl")}"

  vars {
    search_domain = "${data.terraform_remote_state.infra_networking.private_monitoring_domain_name}"
  }
}

resource "aws_ecs_task_definition" "prometheus_server" {
  family                = "prometheus-server"
  container_definitions = "${data.template_file.prometheus_server_container_definition.rendered}"

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

  load_balancer {
    target_group_arn = "${data.terraform_remote_state.app_ecs_albs.monitoring_internal_prometheus_server_tg}"
    container_name   = "prometheus"
    container_port   = 9090
  }
}
