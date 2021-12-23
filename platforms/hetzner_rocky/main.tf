module "machine" {
  source = "../../modules/provider/hetzner"

  server_type    = var.server_type
  image          = "rocky-8"
  machine_prefix = var.machine_prefix
  ssh_keys       = var.ssh_keys
  username       = "root"
  location       = var.location
}

resource "null_resource" "disable_selinux" {
  triggers = {
    machine = module.machine.machine_name
  }

  provisioner "file" {
    destination = "/etc/selinux/config"
    content     = <<EOF
SELINUX=disabled
EOF
  }

  provisioner "remote-exec" {
    inline = [
      "setenforce 0",
    ]
  }

  connection {
    type = "ssh"
    user = "root"
    host = module.machine.public_ip
  }
}

resource "null_resource" "core" {
  triggers = {
    machine = module.machine.machine_name
  }

  depends_on = [
    null_resource.disable_selinux,
  ]

  provisioner "file" {
    destination = "/etc/sudoers.d/00-core"
    content     = <<EOF
core ALL=(ALL) NOPASSWD:ALL
EOF
  }

  provisioner "remote-exec" {
    inline = [
      "adduser core",
      "usermod -aG wheel core",
      "usermod -aG adm core",
      "mkdir /home/core/.ssh",
      "chmod 0700 /home/core/.ssh",
      "cp /root/.ssh/authorized_keys /home/core/.ssh/authorized_keys",
      "chmod 0600 /home/core/.ssh/authorized_keys",
      "chown -R core:core /home/core/.ssh",
    ]
  }

  connection {
    type = "ssh"
    user = "root"
    host = module.machine.public_ip
  }
}

module "podman" {
  count  = var.enable_podman ? 1 : 0
  source = "../../modules/podman"

  depends_on = [
    null_resource.core,
  ]

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

  depends_on = [
    null_resource.core,
  ]

  triggers = {
    machine = module.machine.machine_name
  }

  ssh_ip       = module.machine.public_ip
  ssh_username = "core"
  sync_paths   = var.sync_paths
}
