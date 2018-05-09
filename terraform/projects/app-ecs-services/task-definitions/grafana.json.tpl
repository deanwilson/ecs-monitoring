[
  {
    "name": "grafana",
    "image": "grafana/grafana",
    "cpu": 10,
    "memory": 256,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ],
    "dnsSearchDomains": [
      "${search_domain}"
    ],
    "mountPoints": [
      {
        "sourceVolume": "grafana-config",
        "containerPath": "/etc/grafana/provisioning/datasources/datasource.yaml"
      }
    ],
    "environment": [
      {
        "name": "GF_SECURITY_ADMIN_PASSWORD",
        "value": "secret"
      }
    ]
  }
]
