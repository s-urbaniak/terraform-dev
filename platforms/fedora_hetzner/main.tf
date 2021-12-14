module "os" {
  source = "../../modules/os/fedora"

  username = "root"
}

module "machine" {
  source = "../../modules/provider/hetzner"

  server_type        = var.server_type
  image              = "fedora-${var.fedora_version}"
  machine_prefix     = var.machine_prefix
  provisioner_inline = module.os.init
  ssh_keys           = var.ssh_keys
  username           = "root"
  location           = var.location
}

module "tunnel" {
  source = "../../modules/tunnel"

  username  = "root"
  public_ip = module.machine.public_ip
}
