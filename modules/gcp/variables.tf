variable "provisioner_inline" {
  type    = list(string)
  default = []
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
}

variable "username" {
  type = string
}

variable "ssh_keys" {
  type = list(object({
    publickey = string
    user      = string
  }))
  description = "list of public ssh keys that have access to the VM"
}

variable "image_family" {
  type = string
}

variable "image_project" {
  type = string
}

variable "machine_prefix" {
  type = string
}
