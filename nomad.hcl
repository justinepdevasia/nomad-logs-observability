datacenter = "dc1"
data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"
log_level = "INFO"
    
advertise {
  http = "{{ GetInterfaceIP \"enp8s0\" }}"
  rpc  = "{{ GetInterfaceIP \"enp8s0\" }}"
  serf = "{{ GetInterfaceIP \"enp8s0\" }}"
}

server {
  enabled          = true
  bootstrap_expect = 1
   search {
    fuzzy_enabled   = true
    limit_query     = 200
    limit_results   = 1000
    min_term_length = 5
  }
}

# Enable the client
client {
  enabled = true
  options {
    "driver.raw_exec.enable"    = "1"
    "docker.privileged.enabled" = "true"
  }
  
  server_join {
    retry_join = [ "127.0.0.1" ]
  }

}

plugin "docker" {
  config {
    endpoint = "unix:///var/run/docker.sock"

    extra_labels = ["job_name", "job_id", "task_group_name", "task_name", "namespace", "node_name", "node_id"]

    volumes {
      enabled      = true
      selinuxlabel = "z"
    }

    allow_privileged = true

  }
}

telemetry {
  collection_interval = "15s"
  disable_hostname = true
  prometheus_metrics = true
  publish_allocation_metrics = true
  publish_node_metrics = true
}