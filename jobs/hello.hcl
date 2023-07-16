job "demo-webapp" {
  datacenters = ["dc-fsn1-1"]

  group "demo" {
    count = 3

    network {
      port  "http"{
        to = 80
      }
    }

    service {
      name = "demo-webapp"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.hello.rule=Host(`hello.petrub.dev`)",
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
