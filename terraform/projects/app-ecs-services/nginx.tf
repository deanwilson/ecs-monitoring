data "template_file" "base_nginx_container_definition" {
  template = "${file("task-definitions/base-nginx.json.tpl")}"

  vars {
    search_domain = "${data.terraform_remote_state.infra_networking.private_monitoring_domain_name}"
  }
}

resource "aws_ecs_task_definition" "base_nginx" {
  family                = "nginx"
  container_definitions = "${data.template_file.base_nginx_container_definition.rendered}"

  volume {
    name      = "external-config-password"
    host_path = "/ecs/pulled-config/nginx/.htpasswd"
  }

  volume {
    name      = "external-config-default"
    host_path = "/ecs/pulled-config/nginx/default"
  }
}

resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = "${local.cluster_name}"
  task_definition = "${aws_ecs_task_definition.base_nginx.arn}"
  desired_count   = 1

  #  iam_role        = "${aws_iam_role.foo.arn}" # TODO
  #  depends_on      = ["aws_iam_role_policy.foo"] # TODO as above

  load_balancer {
    target_group_arn = "${data.terraform_remote_state.app_ecs_albs.monitoring_external_tg}"
    container_name   = "nginx"
    container_port   = 80
  }

  /* placement_constraints { */
  /*   type       = "memberOf" */
  /*   expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]" */
  /* } */
}
