variable "internal_service_aliases" {
  type        = "list"
  description = "A list of internal aliases that resolve to the internal ALB"

  default = [
    "metrics-nginx",
    "prometheus-blackbox",
    "prometheus-server",
    "grafana",
  ]
}

### Internal ALB

resource "aws_lb" "monitoring_internal_alb" {
  name               = "${var.stack_name}-int-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = ["${data.terraform_remote_state.infra_security_groups.monitoring_int_alb_sg_id}"]

  subnets = [
    "${element(data.terraform_remote_state.infra_networking.private_subnets, 1)}",
    "${element(data.terraform_remote_state.infra_networking.private_subnets, 2)}",
  ]

  tags = "${merge(
    local.default_tags,
    var.additional_tags,
    map("Stackname", "${var.stack_name}"),
    map("Name", "${var.stack_name}-ecs-monitoring-internal")
  )}"
}

### Prometheus server

resource "aws_lb_target_group" "monitoring_internal_prometheus_server_tg" {
  name     = "${var.stack_name}-int-prom-server-tg"
  port     = 9090
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.infra_networking.vpc_id}"

  health_check {
    interval            = "10"
    path                = "/metrics"
    matcher             = "200"
    port                = "9090"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = "6"
  }
}

resource "aws_lb_listener" "monitoring_internal_prometheus_server" {
  load_balancer_arn = "${aws_lb.monitoring_internal_alb.arn}"
  port              = "9090"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.monitoring_internal_prometheus_server_tg.arn}"
    type             = "forward"
  }
}

### Prometheus blackbox

resource "aws_lb_target_group" "monitoring_internal_prometheus_blackbox_tg" {
  name     = "${var.stack_name}-int-blackbox-tg"
  port     = 9115
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.infra_networking.vpc_id}"

  health_check {
    interval            = "10"
    path                = "/metrics"
    matcher             = "200"
    port                = "9115"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = "6"
  }
}

resource "aws_lb_listener" "monitoring_internal_prometheus_blackbox" {
  load_balancer_arn = "${aws_lb.monitoring_internal_alb.arn}"
  port              = "9115"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.monitoring_internal_prometheus_blackbox_tg.arn}"
    type             = "forward"
  }
}

### Grafana

resource "aws_lb_target_group" "monitoring_internal_grafana_tg" {
  name     = "${var.stack_name}-int-grafana-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "${data.terraform_remote_state.infra_networking.vpc_id}"

  health_check {
    interval            = "10"
    path                = "/metrics"
    matcher             = "200"
    port                = "3000"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = "6"
  }
}

resource "aws_lb_listener" "monitoring_internal_grafana" {
  load_balancer_arn = "${aws_lb.monitoring_internal_alb.arn}"
  port              = "3000"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.monitoring_internal_grafana_tg.arn}"
    type             = "forward"
  }
}

### Add DNS Aliases
# Add all the aliases that should point to the internal load balancer

resource "aws_route53_record" "internal_service_aliases" {
  count   = "${length(var.internal_service_aliases)}"
  zone_id = "${data.terraform_remote_state.infra_dns_discovery.private_monitoring_zone_id}"
  name    = "${element(var.internal_service_aliases, count.index)}.${data.terraform_remote_state.infra_dns_discovery.private_monitoring_domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_lb.monitoring_internal_alb.dns_name}"
    zone_id                = "${aws_lb.monitoring_internal_alb.zone_id}"
    evaluate_target_health = false                                        /* TODO */
  }
}

## Outputs

output "monitoring_internal_prometheus_server_tg" {
  value       = "${aws_lb_target_group.monitoring_internal_prometheus_server_tg.arn}"
  description = "Prometheus server internal ALB target group"
}

output "monitoring_internal_blackbox_tg" {
  value       = "${aws_lb_target_group.monitoring_internal_prometheus_blackbox_tg.arn}"
  description = "Prometheus server internal ALB target group"
}

output "monitoring_internal_grafana_tg" {
  value       = "${aws_lb_target_group.monitoring_internal_grafana_tg.arn}"
  description = "Grafana internal ALB target group"
}

output "monitoring_internal_dns" {
  value       = "${aws_lb.monitoring_internal_alb.dns_name}"
  description = "Internal Monitoring ALB DNS name"
}
