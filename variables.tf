variable "hcloud_token" {
  default = ""
  description = "Hetzner Cloud API token"
}

variable "prefix" {
    type = string
    default = "nomad-tf"
}

variable "server_name" {
  description = "The name of the server"
  type = string
  default = "nomad-tf"
}

variable "server_location" {
  description = "Location of the server"
  type = string
  default = "fsn1"
}

variable "server_type" {
  description = "The type of server to run for each node in the cluster"
  type = string
  default = "cax11"
}

variable "server_image" {
  description = "The image of the server"
  type = string
  default = "ubuntu-22.04"
}

variable "server_count" {
  description = "Number of servers (Default: 3)"
  type = number
  default = 3
}

variable "enable_letsencrypt" {
  description = "Enable cert provisioning via Let's Encrypt"
  type = bool
  default = true
}

variable "dns_host" {
  description = "The DNS host to use for construction of the root domain for apps"
  type = string
  default = "sslip.io"
}

variable "allowed_ssh_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the server will allow SSH connections"
  type = list(string)
  default = [ "0.0.0.0/0" ]
}

variable "allowed_inbound_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges from which the server will allow connections"
  type = list(string)
  default = [ "0.0.0.0/0" ]
}

variable "allow_outbound_cidr_blocks" {
  description = "Allow outbound traffic to these CIDR blocks"
  type        = list(string)
  default = [ "0.0.0.0/0" ]
}

variable "allow_inbound_http_nomad" {
  description = "Allow inbound connections to the unsecured NOMAD API http port"
  type = bool
  default = false
}

variable "allow_inbound_http_consul" {
  description = "Allow inbound connections to the unsecured Consul API http port"
  type = bool
  default = false
}