variable "server_type" {
  type = string
}

variable "ssh_key" {
  type        = string
  description = "list of public ssh keys that have access to the VM"
  default     = ""
}

variable "image" {
  type    = string
  default = "centos-stream-9"
}

variable "machine_prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "ports" {
  type        = list(number)
  description = "list of ports to be opened in the firewall"
  default = [
    22,
  ]
}
