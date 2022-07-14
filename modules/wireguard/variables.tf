variable "clients" {
  type    = list(any)
  default = []
}

variable "ssh_username" {
  type    = string
  default = "core"
}

variable "server_ip" {
  type = string
}
