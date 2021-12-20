module "machine" {
  source = "../../modules/provider/gcp"

  image_family   = "rocky-linux-8"
  image_project  = "rocky-linux-cloud"
  machine_prefix = var.machine_prefix
  machine_type   = var.machine_type
  project        = var.project
  region         = var.region
  ssh_keys       = var.ssh_keys
  zone           = var.zone
}

module "podman" {
  count  = var.enable_podman ? 1 : 0
  source = "../../modules/podman"

  triggers = {
    machine = module.machine.machine_name
  }

  ssh_ip       = module.machine.public_ip
  ssh_username = "core"
}

module "wireguard" {
  count  = var.enable_wireguard ? 1 : 0
  source = "../../modules/wireguard"

  depends_on = [
    module.podman,
  ]

  triggers = {
    machine = module.machine.machine_name
  }

  server_ip    = module.machine.public_ip
  ssh_username = "core"
}

module "kind" {
  count  = var.enable_podman && var.enable_kind ? 1 : 0
  source = "../../modules/kind"

  depends_on = [
    module.wireguard,
  ]

  triggers = {
    machine = module.machine.machine_name
  }

  ssh_ip       = module.machine.public_ip
  ssh_username = "core"
}

module "mutagen" {
  count  = var.enable_sync ? 1 : 0
  source = "../../modules/mutagen"

  triggers = {
    machine = module.machine.machine_name
  }

  ssh_ip       = module.machine.public_ip
  ssh_username = "core"
  sync_paths   = var.sync_paths
}
