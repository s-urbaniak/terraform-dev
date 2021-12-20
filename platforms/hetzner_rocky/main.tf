module "machine" {
  source = "../../modules/provider/hetzner"

  server_type    = var.server_type
  image          = "rocky-8"
  machine_prefix = var.machine_prefix
  ssh_keys       = var.ssh_keys
  username       = "root"
  location       = var.location
}

module "podman" {
  count = var.enable_podman ? 1 : 0
  source = "../../modules/podman"

  triggers = {
    machine = module.machine.machine_name
  }

  ssh_ip       = module.machine.public_ip
  ssh_username = "root"
}

module "wireguard" {
  count = var.enable_wireguard ? 1 : 0
  source = "../../modules/wireguard"

  depends_on = [
    module.podman,
  ]

  triggers = {
    machine = module.machine.machine_name
  }

  server_ip    = module.machine.public_ip
  ssh_username = "root"
}

module "kind" {
  count = var.enable_podman && var.enable_kind ? 1 : 0
  source = "../../modules/kind"

  depends_on = [
    module.wireguard,
  ]

  triggers = {
    machine = module.machine.machine_name
  }

  ssh_ip       = module.machine.public_ip
  ssh_username = "root"
}

module "mutagen" {
  count  = var.enable_sync ? 1 : 0
  source = "../../modules/mutagen"

  triggers = {
    machine = module.machine.machine_name
  }

  ssh_ip       = module.machine.public_ip
  ssh_username = "root"
  sync_paths   = var.sync_paths
}
