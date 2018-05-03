resource "aws_ecs_task_definition" "cadvisor" {
  family                = "cadvisor"
  container_definitions = "${file("task-definitions/cadvisor.json")}"

  volume {
    name      = "root"
    host_path = "/"
  }

  volume {
    name      = "var_run"
    host_path = "/var/run"
  }

  volume {
    name      = "sys"
    host_path = "/sys"
  }

  volume {
    name      = "var_lib_docker"
    host_path = "/var/lib/docker/"
  }
}

resource "aws_ecs_service" "cadvisor" {
  name            = "cadvisor"
  cluster         = "${local.cluster_name}"
  task_definition = "${aws_ecs_task_definition.cadvisor.arn}"
  desired_count   = 1
}
