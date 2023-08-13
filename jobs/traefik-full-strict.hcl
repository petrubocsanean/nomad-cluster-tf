job "traefik" {
  region      = "global"
  datacenters = ["dc-fsn1-1"]
  type        = "service"

  group "traefik" {
    count = 1

    network {
      port "http" {
        static = 80
      }

      port "websecure" {
        static = 443
      }

      port "api" {
        static = 8081
      }
    }

    service {
      name = "traefik"

      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image        = "traefik:v2.2"
        network_mode = "host"

        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]
      }

      template {
        data        = <<EOF
<INSERT HERE THE PRIVATE CERTIFICATE>
EOF
        destination = "local/private.pem"
      }

      template {
        data        = <<EOF
<INSERT HERE THE PRIVATE KEY>
EOF
        destination = "local/private.key"
      }

      template {
        data = <<EOF
[[tls.certificates]]
  certFile = "/private.pem"
  keyFile = "/private.key"
[entryPoints]
    [entryPoints.http]
    address = ":80"
    [entryPoints.websecure]
    address = ":443"
    [entryPoints.traefik]
    address = ":8081"

[api]
    dashboard = true
    insecure  = true
[providers.file]
    filename = "local/traefik.toml"
# Enable Consul Catalog configuration backend.
[providers.consulCatalog]
    prefix           = "traefik"
    exposedByDefault = false

    [providers.consulCatalog.endpoint]
      address = "127.0.0.1:8500"
      scheme  = "http"
EOF

        destination = "local/traefik.toml"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}
