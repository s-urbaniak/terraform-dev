variable "triggers" {
  type = map
}

variable "clients" {
    type = list
    default = []
}

variable "ssh_username" {
    type = string
}

variable "server_ip" {
    type = string
}
