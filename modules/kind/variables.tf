variable "ssh_username" {
  type    = string
  default = "core"
}

variable "ssh_ip" {
  type = string
}

variable "kind_version" {
  type    = string
  default = "v0.14.0"
}

variable "kind_startup_options" {
  type    = string
  default = ""
}

variable "kind_config" {
  type    = string
  default = ""
}

variable "use_podman" {
  type    = bool
  default = false
}
