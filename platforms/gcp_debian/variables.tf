variable "machine_prefix" {
  type = string
}

variable "debian_version" {
  type    = string
  default = "11"
}

variable "kind_url" {
  type    = string
  default = "https://github.com/kubernetes-sigs/kind/releases/download/v0.11.1/kind-linux-amd64"
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
  default = "e2-standard-4"
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
