variable "machine_prefix" {
  type = string
}

variable "ssh_key" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.xlarge"
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
