[
  {
    "name": "prometheus-blackbox",
    "image": "prom/blackbox-exporter",
    "cpu": 10,
    "memory": 256,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 9115,
        "hostPort": 9115
      }
    ],
    "dnsSearchDomains": [
      "${search_domain}"
    ]
  }
]
