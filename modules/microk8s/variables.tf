variable "ssh_username" {
  type    = string
  default = "core"
}

variable "ssh_ip" {
  type = string
}

variable "kubeconfig_filename" {
  type    = string
  default = "kubeconfig_u8ks"
}

variable "channel" {
  type    = string
  default = "1.24/stable"
}

variable "addons" {
  type        = list(string)
  description = "list of addons to be enabled"
  default = [
    "dns",
    "registry",
    "host-access",
    "rbac",
    "ingress",
    "hostpath-storage",
  ]
}
