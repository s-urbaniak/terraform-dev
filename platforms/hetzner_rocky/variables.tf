variable "machine_prefix" {
  type = string
}

variable "ssh_keys" {
  type = list(object({
    publickey = string
    user      = string
  }))
  description = "list of public ssh keys that have access to the VM"
}

variable "location" {
  type = string
}

variable "server_type" {
  type    = string
  default = "cx21"
}

variable "enable_podman" {
  type    = bool
  default = true
}

variable "enable_wireguard" {
  type    = bool
  default = true
}

variable "enable_kind" {
  type    = bool
  default = true
}

variable "enable_sync" {
  type    = bool
  default = false
}

variable "sync_paths" {
  type    = list(any)
  default = []
}
