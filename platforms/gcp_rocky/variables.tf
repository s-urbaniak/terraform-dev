variable "machine_prefix" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "machine_type" {
  type    = string
  default = "e2-standard-8"
}

variable "ssh_keys" {
  type = list(object({
    publickey = string
    user      = string
  }))
  description = "list of public ssh keys that have access to the VM"
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
  type = list
  default = []
}
