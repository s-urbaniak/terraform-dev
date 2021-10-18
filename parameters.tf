variable "gcp_project" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "gcp_zone" {
  type = string
}

variable "machine_prefix" {
  type = string
}

variable "os_image" {
  type = string
}

variable "username" {
  type = string
}

variable "kind_url" {
  type = string
}

variable "ssh_keys" {
  type = list(object({
    publickey = string
    user = string
  }))
  description = "list of public ssh keys that have access to the VM"
}