#!/usr/bin/env bash

# ---
# Arguments
# ---

INSTANCE_NUMBER=$1
REGION_NAME=$2
SERVER_IPS=$3
IP_RANGE=$4

# ---
# Variables
# ---
LOCAL_IP=$(curl -s http://169.254.169.254/hetzner/v1/metadata/private-networks | awk '/ip:/ {print $3}')

# ---
# Consul configuration
# ---
cat > /etc/consul.d/consul.hcl <<EOF
datacenter = "dc-$REGION_NAME-1"
data_dir = "/opt/consul"

node_name = "consul-client-$INSTANCE_NUMBER"

bind_addr = "{{ GetPrivateInterfaces | include \"network\" \"${IP_RANGE}\" | attr \"address\" }}"
client_addr = "0.0.0.0"

retry_join = $SERVER_IPS

connect {
    enabled = true
}

ports {
    grpc = 8502
}
EOF

# ---
# Nomad configuration
# ---

cat > /etc/nomad.d/nomad.hcl <<EOF
datacenter = "dc-$REGION_NAME-1"
data_dir = "/opt/nomad/data"

bind_addr = "0.0.0.0"

name = "nomad-client-$INSTANCE_NUMBER"

client {
    enabled = true
    options {
        "driver.raw_exec.enable" = "1"
        "docker.privileged.enabled" = "true"
    }
}

advertise {
  # Advertise to the private network ip.
  http = "$LOCAL_IP"
  rpc  = "$LOCAL_IP"
  serf = "$LOCAL_IP"
}

consul {
    address = "127.0.0.1:8500"
    auto_advertise   = true
    server_service_name = "nomad"
}

ui {
    enabled = false
}
EOF

# ---
# Running Consul
# ---
systemctl enable consul
systemctl start consul

# ---
# Running Nomad
# ---
systemctl enable nomad
systemctl start nomad
