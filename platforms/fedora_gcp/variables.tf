variable "machine_prefix" {
  type = string
}

variable "fedora_channel" {
  type    = string
  default = "stable"
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
  type = string
  default = "e2-standard-8"
}

variable "ssh_keys" {
  type = list(object({
    publickey = string
    user      = string
  }))
  description = "list of public ssh keys that have access to the VM"
}
