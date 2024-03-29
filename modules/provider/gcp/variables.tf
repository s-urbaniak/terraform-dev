variable "machine_type" {
  type    = string
  default = "e2-standard-8"
}

variable "ssh_key" {
  type        = string
  description = "list of public ssh keys that have access to the VM"
}

variable "image_family" {
  type    = string
  default = "centos-stream-9"
}

variable "image_project" {
  type    = string
  default = "centos-cloud"
}

variable "machine_prefix" {
  type = string
}

variable "disk_size" {
  type        = number
  default     = 100
  description = "The disk size of the machines in gigabytes"
}

variable "ports" {
  type        = list(number)
  description = "list of ports to be opened in the firewall"
  default = [
    22,
  ]
}
