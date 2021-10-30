module "debian" {
  source = "../../modules/debian"

  kind_url = var.kind_url
  username = var.username
}

module "machine" {
  source = "../../modules/gcp"

  image_family       = "debian-${var.debian_version}"
  image_project      = "debian-cloud"
  machine_prefix     = var.machine_prefix
  machine_type       = var.machine_type
  project            = var.project
  provisioner_inline = split("\n", module.debian.init)
  region             = var.region
  ssh_keys           = var.ssh_keys
  username           = var.username
  zone               = var.zone
}

module "tunnel" {
  source = "../../modules/tunnel"

  username  = var.username
  public_ip = module.machine.public_ip
}
