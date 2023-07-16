job "traefik" {
  datacenters = ["dc-fsn1-1"]
  type        = "system"

  group "traefik" {
    network {
      port "web" {
        static = 80
      }

      port "websecure" {
        static = 443
      }
    }

    service {
      name = "traefik"
      port = "web"

      check {
        type     = "http"
        path     = "/ping"
        port     = "web"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image        = "traefik:v2.10.3"
        network_mode = "host"

        volumes = [
          "local/traefik.yaml:/etc/traefik/traefik.yaml",
        ]
      }

      template {
        data = <<EOF
entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"
  traefik:
    address: ":8081"
api:
  dashboard: true
  insecure: true
ping:
  entryPoint: "web"
providers:
  consulCatalog:
    prefix: "traefik"
    exposedByDefault: false
    endpoint:
      address: "127.0.0.1:8500"
      scheme: "http"
certificatesResolvers:
  letsencrypt-tls:
    acme:
      # Supply an email to get cert expiration notices
      # email = "you@example.com"
      # The CA server is toggled to staging for testing/avoiding rate limits
      caServer: https://acme-staging-v02.api.letsencrypt.org/directory
      storage: "/acme.json"
      tlsChallenge: true
EOF

        destination = "local/traefik.yaml"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}