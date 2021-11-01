variable "machine_prefix" {
  type = string
}

variable "debian_version" {
  type    = string
  default = "11"
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
