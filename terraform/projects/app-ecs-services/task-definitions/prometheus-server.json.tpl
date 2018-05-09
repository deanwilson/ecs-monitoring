[
  {
    "name": "prometheus",
    "image": "prom/prometheus",
    "cpu": 10,
    "memory": 256,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 9090,
        "hostPort": 9090
      }
    ],
    "dnsSearchDomains": [
      "${search_domain}"
    ],
    "mountPoints": [
      {
        "sourceVolume": "prometheus-config",
        "containerPath": "/etc/prometheus/prometheus.yml"
      },
      {
        "sourceVolume": "alert-config",
        "containerPath": "/etc/prometheus/alerts/alerts.default"
      }
    ]
  }
]
