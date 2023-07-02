#!/usr/bin/env bash

# ---
# Arguments
# ---
INSTANCE_NUMBER=$1
NUMBER_OF_INSTANCES=$2
REGION_NAME=$3
SERVER_IPS=$4
IP_RANGE=$5

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

node_name = "consul-server-$INSTANCE_NUMBER"

bind_addr = "{{ GetPrivateInterfaces | include \"network\" \"${IP_RANGE}\" | attr \"address\" }}"
client_addr = "0.0.0.0"

bootstrap_expect = $NUMBER_OF_INSTANCES

ui_config {
  enabled = true
}

server = true

retry_join = ${SERVER_IPS}

service {
    name = "consul"
}

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

name = "nomad-server-$INSTANCE_NUMBER"

server {
    enabled = true
    bootstrap_expect = $NUMBER_OF_INSTANCES
}

advertise {
  # Advertise to the private network ip.
  http = "$LOCAL_IP"
  rpc  = "$LOCAL_IP"
  serf = "$LOCAL_IP"
}

consul {
    address = "127.0.0.1:8500"
}
EOF

# ---
# Enable both services on all servers
# ---
systemctl enable consul
systemctl enable nomad

# ---
# and start the services
# ---
systemctl start consul
systemctl start nomad
