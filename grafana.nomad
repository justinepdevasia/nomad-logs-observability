	job "grafana" {
  datacenters = ["dc1"]
  type        = "service"
  

  group "grafana" {
    count = 1

    network {
      mode = "host"

      port "grafana" {
        to = 3000
        static = 3000
      }
    }

    task "grafana" {
      driver = "docker"

      env {
        GF_LOG_LEVEL          = "ERROR"
        GF_LOG_MODE           = "console"
        GF_PATHS_DATA         = "/var/lib/grafana"
      }

      user = "root"

      config {
        image = "grafana/grafana:10.4.2"
        ports = ["grafana"]
        volumes = ["/grafana_volume:/var/lib/grafana"]
      }

      resources {
        cpu    = 2000
        memory = 2000
      }

    }
  }

}