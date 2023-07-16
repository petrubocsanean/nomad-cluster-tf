job "demo-webapp" {
  datacenters = ["dc-fsn1-1"]

  group "demo" {
    count = 3

    network {
      port  "http"{
        to = 8080
      }
    }

    service {
      name = "demo-webapp"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.hello.rule=Host(`hello.petrub.dev`)",
        "traefik.http.routers.hello.entryPoints=websecure",
        "traefik.http.routers.hello.tls=true",
        "traefik.http.routers.hello.tls.certresolver=letsencrypt-tls",
      ]

      check {
        type     = "http"
        path     = "/"
        interval = "2s"
        timeout  = "2s"
      }
    }

    task "hello" {
      driver = "docker"

      config {
        image = "nginxdemos/nginx-hello"
        ports = ["http"]
      }
    }
  }
}
