job "vector" {
  datacenters = ["dc1"]
  # system job, runs on all nodes
  type = "system"

  group "vector" {
    count = 1

    network {
      port "api" {
        to = 8686
      }
    }

    ephemeral_disk {
      size    = 500
      sticky  = true
    }

    task "vector" {
      driver = "docker"
      config {
        image = "timberio/vector:0.30.0-debian"
        ports = ["api"]
        volumes = ["/var/run/docker.sock:/var/run/docker.sock"]
      }
      # Vector won't start unless the sinks(backends) configured are healthy
      env {
        VECTOR_CONFIG = "local/vector.toml"
        VECTOR_REQUIRE_HEALTHY = "false"
      }
      # resource limits are a good idea because you don't want your log collection to consume all resources available
      resources {
        cpu    = 100 # 100 MHz
        memory = 100 # 100MB
      }
      # template with Vector's configuration
      template {
        destination = "local/vector.toml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        # overriding the delimiters to [[ ]] to avoid conflicts with Vector's native templating, which also uses {{ }}
        left_delimiter = "[["
        right_delimiter = "]]"
        data=<<EOH
          data_dir = "alloc/data/vector/"
          [api]
            enabled = true
            address = "0.0.0.0:8686"
            playground = true
          [sources.logs]
            type = "docker_logs"
          [sinks.out]
            type = "console"
            inputs = [ "logs" ]
            encoding.codec = "json"
            target = "stdout"
          [sinks.loki]
            type = "loki"
            compression = "snappy"
            encoding.codec = "json"
            inputs = ["logs"] 
            endpoint = "http://[[ range nomadService "loki" ]][[.Address]]:[[.Port]][[ end ]]"
            healthcheck.enabled = true
            out_of_order_action = "drop"
            # remove fields that have been converted to labels to avoid having the field twice
            remove_label_fields = true
              [sinks.loki.labels]
              # See https://vector.dev/docs/reference/vrl/expressions/#path-example-nested-path
              job = "{{label.\"com.hashicorp.nomad.job_name\" }}"
              task = "{{label.\"com.hashicorp.nomad.task_name\" }}"
              group = "{{label.\"com.hashicorp.nomad.task_group_name\" }}"
              namespace = "{{label.\"com.hashicorp.nomad.namespace\" }}"
              node = "{{label.\"com.hashicorp.nomad.node_name\" }}"
        EOH
      }
      kill_timeout = "30s"
    }
  }
}