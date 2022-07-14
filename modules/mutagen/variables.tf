variable "sync_paths" {
  type    = list(any)
  default = []
}

variable "ssh_ip" {
  type = string
}

variable "ssh_username" {
  type    = string
  default = "core"
}
