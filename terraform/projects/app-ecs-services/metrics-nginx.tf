data "template_file" "metrics_nginx_container_definition" {
  template = "${file("task-definitions/metrics-nginx.json.tpl")}"

  vars {
    search_domain = "${data.terraform_remote_state.infra_dns_discovery.private_monitoring_domain_name}"
  }
}

resource "aws_ecs_task_definition" "metrics_nginx" {
  family                = "metrics-nginx"
  container_definitions = "${data.template_file.metrics_nginx_container_definition.rendered}"

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
}
