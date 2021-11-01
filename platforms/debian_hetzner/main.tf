module "debian" {
  source = "../../modules/kind_debian"

  username = "root"
}

module "machine" {
  source = "../../modules/hetzner"

  server_type        = var.server_type
  image              = "debian-${var.debian_version}"
  machine_prefix     = var.machine_prefix
  provisioner_inline = split("\n", module.debian.init)
  ssh_keys           = var.ssh_keys
  username           = "root"
  location           = var.location
}

module "tunnel" {
  source = "../../modules/tunnel"

  username  = "root"
  public_ip = module.machine.public_ip
}
