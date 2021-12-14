module "os" {
  source = "../../modules/os/fedora-coreos"

  username = "core"
}

module "machine" {
  source = "../../modules/provider/gcp"

  image_family       = "fedora-coreos-${var.fedora_channel}"
  image_project      = "fedora-coreos-cloud"
  machine_prefix     = var.machine_prefix
  machine_type       = var.machine_type
  project            = var.project
  provisioner_inline = module.os.init
  region             = var.region
  ssh_keys           = var.ssh_keys
  username           = "core"
  zone               = var.zone
}

module "tunnel" {
  source = "../../modules/tunnel"

  username  = "core"
  public_ip = module.machine.public_ip
  kind_path = "/var/home/core/kind"
}
