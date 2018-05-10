data "template_file" "grafana_container_definition" {
  template = "${file("task-definitions/grafana.json.tpl")}"

  vars {
    search_domain = "${data.terraform_remote_state.infra_networking.private_monitoring_domain_name}"
  }
}

resource "aws_ecs_task_definition" "grafana_server" {
  family                = "grafana-server"
  container_definitions = "${data.template_file.grafana_container_definition.rendered}"

  volume {
    name      = "grafana-config"
    host_path = "/ecs/pulled-config/grafana/datasource.yaml"
  }
}

resource "aws_ecs_service" "grafana_server" {
  name            = "grafana-server"
  cluster         = "${local.cluster_name}"
  task_definition = "${aws_ecs_task_definition.grafana_server.arn}"
  desired_count   = 1

  load_balancer {
    target_group_arn = "${data.terraform_remote_state.app_ecs_albs.monitoring_internal_grafana_tg}"
    container_name   = "grafana"
    container_port   = 3000
  }
}
