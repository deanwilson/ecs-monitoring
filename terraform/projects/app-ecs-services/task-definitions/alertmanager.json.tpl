[
  {
    "name": "alertmanager",
    "image": "prom/alertmanager",
    "cpu": 10,
    "memory": 256,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 9093,
        "hostPort": 9093
      }
    ],
    "dnsSearchDomains": [
      "${search_domain}"
    ],
    "command": [
      "--log.level=debug",
      "--config.file=/alertmanager.yml"
    ],
    "mountPoints": [
      {
        "sourceVolume": "alertmanager-config",
        "containerPath": "/alertmanager.yml"
      }
    ]
  }
]
