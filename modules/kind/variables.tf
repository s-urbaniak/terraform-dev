variable "ssh_username" {
  type = string
}

variable "ssh_ip" {
  type = string
}

variable "kind_url" {
  type    = string
  default = "https://github.com/kubernetes-sigs/kind/releases/download/v0.11.1/kind-linux-amd64"
}

variable "triggers" {
  type = map(any)
}

variable "kind_startup_options" {
  type    = string
  default = ""
}

variable "kind_config" {
  type    = string
  default = ""
}
