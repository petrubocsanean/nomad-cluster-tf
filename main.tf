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
# Server config
# ---------------------------

resource "hcloud_server" "first_server" {
    count = var.server_count - 2
    name = "${var.server_name}-${count.index}"
    server_type = var.server_type
    location = var.server_location
    image = var.server_image
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

    depends_on = [ 
        hcloud_network_subnet.nomad-network-subnet
     ]
}

resource "hcloud_server" "other_servers" {
    count = var.server_count - 1
    name = "${var.server_name}-${count.index + 1}"
    server_type = var.server_type
    location = var.server_location
    image = var.server_image
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

    depends_on = [ 
        hcloud_network_subnet.nomad-network-subnet
     ]
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

