# ---------------------------
# Private Network config
# ---------------------------

resource "hcloud_network" "nomad-network" {
    name = "${var.prefix}-pn"
    ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "nomad-network-subnet" {
  type = "cloud"
  network_id = hcloud_network.nomad-network.id
  network_zone = "eu-central"
  ip_range = "10.0.0.0/24"
}

# ---------------------------
# Nomad Servers config
# ---------------------------
resource "hcloud_server" "nomad_servers" {
  name = "nomad-server-${count.index + 1}"
  count = var.server_count
  image = var.vm_image
  location = var.location
  server_type = var.server_type
  ssh_keys = [ hcloud_ssh_key._.id ]
  
  network {
    network_id = hcloud_network.nomad-network.id
  }

  connection {
    host = self.ipv4_address
    type = "ssh"
    user = "root"
    private_key = tls_private_key.ssh.private_key_pem
  }

  depends_on = [ hcloud_network_subnet.nomad-network-subnet ]

  provisioner "file" {
    source = "scripts/nomad-installations.sh"
    destination = "/tmp/nomad-installations.sh"
  }

  provisioner "remote-exec" {
    inline = [ 
      # Add executable permission to the sript.
      "chmod +x /tmp/nomad-installations.sh",
      "/tmp/nomad-installations.sh"
     ]
  }
}

# ---------------------------
# Nomad Clients config
# ---------------------------
resource "hcloud_server" "nomad_clients" {
  name = "nomad-client-${count.index + 1}"
  count = var.client_count
  image = var.vm_image
  location = var.location
  server_type = var.server_type
  ssh_keys = [ hcloud_ssh_key._.id ]
  
  network {
    network_id = hcloud_network.nomad-network.id
  }

  connection {
    host = self.ipv4_address
    type = "ssh"
    user = "root"
    private_key = tls_private_key.ssh.private_key_pem
  }

  depends_on = [ hcloud_network_subnet.nomad-network-subnet ]

  provisioner "file" {
    source = "scripts/nomad-installations.sh"
    destination = "/tmp/nomad-installations.sh"
  }

  provisioner "remote-exec" {
    inline = [ 
      # Add executable permission to the sript.
      "chmod +x /tmp/nomad-installations.sh",
      "/tmp/nomad-installations.sh"
     ]
  }
}

# ---------------------------
# Nomad Servers setup
# ---------------------------
resource "null_resource" "nomad_servers_post_script" {
  count = var.server_count
  depends_on = [ hcloud_server.nomad_servers ]

  connection {
    type = "ssh"
    user = "root"
    host = hcloud_server.nomad_servers[count.index].ipv4_address
    private_key = tls_private_key.ssh.private_key_pem
  }

  provisioner "file" {
    source = "scripts/nomad-server-setup.sh"
    destination = "/tmp/nomad-server-setup.sh"
  }

  provisioner "remote-exec" {
    inline = [ 
      # Add executable permission to the script.
      "chmod +x /tmp/nomad-server-setup.sh",
      "/tmp/nomad-server-setup.sh ${count.index + 1} ${var.server_count} ${var.location} ${jsonencode([for server in hcloud_server.nomad_servers : "\"${(server.network[*].ip)[0]}\""])} ${hcloud_network.nomad-network.ip_range}"
     ]
  }
}
# ---------------------------
# Nomad Clients setup
# ---------------------------
resource "null_resource" "nomad_clients_post_script" {
  count = var.client_count
  depends_on = [ hcloud_server.nomad_clients, null_resource.nomad_servers_post_script ]

  connection {
    type = "ssh"
    user = "root"
    host = hcloud_server.nomad_clients[count.index].ipv4_address
    private_key = tls_private_key.ssh.private_key_pem
  }

  provisioner "file" {
    source = "scripts/nomad-client-setup.sh"
    destination = "/tmp/nomad-client-setup.sh"
  }

  provisioner "remote-exec" {
    inline = [ 
      # Add executable permission to the script.
      "chmod +x /tmp/nomad-client-setup.sh",
      "/tmp/nomad-client-setup.sh ${count.index + 1} ${var.location} ${jsonencode([for server in hcloud_server.nomad_servers : "\"${(server.network[*].ip)[0]}\""])} ${hcloud_network.nomad-network.ip_range}"
     ]
  }
}


# ---------------------------
# SSH config
# ---------------------------

resource "hcloud_ssh_key" "_" {
  name = var.prefix
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits = "4096"
}

resource "local_file" "ssh_private_key" {
  content = tls_private_key.ssh.private_key_pem
  filename = "hetzner_ssh_key"
  file_permission = "0600"
}

resource "local_file" "ssh_public_key" {
  content = tls_private_key.ssh.public_key_openssh
  filename = "hetzner_ssh_key.pub"
  file_permission = "0600"
}

