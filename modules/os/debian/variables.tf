variable "username" {
  type = string
}

variable "kind_url" {
  type    = string
  default = "https://github.com/kubernetes-sigs/kind/releases/download/v0.11.1/kind-linux-amd64"
}
