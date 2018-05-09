[
  {
    "name": "nginx",
    "image": "nginx",
    "cpu": 10,
    "memory": 256,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
    "dnsSearchDomains": [
      "${search_domain}"
    ],
    "mountPoints": [
      {
        "sourceVolume": "metrics-nginx",
        "containerPath": "/etc/nginx/conf.d/default.conf"
      }
    ]
  }
]
