[
  {
    "name": "nginx",
    "image": "nginx",
    "cpu": 10,
    "memory": 256,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "dnsSearchDomains": [
      "${search_domain}"
    ],
    "mountPoints": [
      {
        "sourceVolume": "external-config-password",
        "containerPath": "/etc/nginx/.htpasswd"
      },
      {
        "sourceVolume": "external-config-default",
        "containerPath": "/etc/nginx/conf.d/default.conf"
      }
    ]
  }
]
