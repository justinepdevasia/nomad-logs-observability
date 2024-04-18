job "logger" {
  datacenters = ["dc1"]

  type = "service"

  group "logger" {
    count = 1

    task "logger" {

      driver = "docker"

      config {
        image = "chentex/random-logger:latest"
      }

      resources {
        cpu    = 100 # 100 MHz
        memory = 100 # 100MB
      }


    }
  }
}
