data "template_file" "prometheus_blackbox_container_definition" {
  template = "${file("task-definitions/prometheus-blackbox.json.tpl")}"

  vars {
    search_domain = "${data.terraform_remote_state.infra_dns_discovery.private_monitoring_domain_name}"
  }
}

resource "aws_ecs_task_definition" "prometheus_blackbox" {
  family                = "prometheus-blackbox"
  container_definitions = "${data.template_file.prometheus_blackbox_container_definition.rendered}"
}

resource "aws_ecs_service" "prometheus_blackbox" {
  name            = "prometheus-blackbox"
  cluster         = "${local.cluster_name}"
  task_definition = "${aws_ecs_task_definition.prometheus_blackbox.arn}"
  desired_count   = 1
}
