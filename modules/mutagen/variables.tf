variable "sync_paths" {
  type    = list(any)
  default = []
}

variable "triggers" {
  type = map(any)
}

variable "ssh_ip" {
  type = string
}

variable "ssh_username" {
  type = string
}
