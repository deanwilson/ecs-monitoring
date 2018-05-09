data "template_file" "alertmanager_container_definition" {
  template = "${file("task-definitions/alertmanager.json.tpl")}"

  vars {
    search_domain = "${data.terraform_remote_state.infra_dns_discovery.private_monitoring_domain_name}"
  }
}

resource "aws_ecs_task_definition" "alertmanager" {
  family                = "alertmanager"
  container_definitions = "${data.template_file.alertmanager_container_definition.rendered}"

  volume {
    name      = "alertmanager-config"
    host_path = "/ecs/pulled-config/alertmanager/alertmanager.yml"
  }
}

resource "aws_ecs_service" "alertmanager" {
  name            = "alertmanager"
  cluster         = "${local.cluster_name}"
  task_definition = "${aws_ecs_task_definition.alertmanager.arn}"
  desired_count   = 1
}
