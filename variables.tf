variable "hcloud_token" {
  default = ""
  description = "Hetzner Cloud API token."
}

# variable "ssh_keys" {
#   description = "List of SSH keys to use for connecting to the instances."  
# }

variable "prefix" {
  description = "Prefix tag to use for the cluster."
  default = "NCLUSTER"
}

variable "location" {
  description = "The Hetzner region for the instances."
  type = string
  default = "fsn1"
}

variable "vm_image" {
  description = "The image to use for the instances."
  type = string
  default = "ubuntu-22.04"
}

variable "server_count" {
  description = "The number of Nomad/Consul server instances."
  type = number
  default = 2
}

variable "client_count" {
  description = "The number of Nomad/Consul client instances."
  type = number
  default = 2
}

variable "server_type" {
  description = "The instance type for the server instances"
  default = "cax11"
}

variable "client_type" {
  description = "The instance type for the client instances"
  default = "cax11"
}