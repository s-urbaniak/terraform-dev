variable "provisioner_inline" {
  type    = list(string)
  default = []
}

variable "username" {
  type = string
}

variable "server_type" {
    type = string
}

variable "ssh_keys" {
  type = list(object({
    publickey = string
    user      = string
  }))
  description = "list of public ssh keys that have access to the VM"
}

variable "image" {
  type = string
}

variable "machine_prefix" {
  type = string
}

variable "location" {
  type = string
}