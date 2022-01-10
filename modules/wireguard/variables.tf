variable "triggers" {
  type = map(any)
}

variable "clients" {
  type    = list(any)
  default = []
}

variable "ssh_username" {
  type = string
}

variable "server_ip" {
  type = string
}
