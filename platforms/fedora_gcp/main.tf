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
}

resource "null_resource" "podman" {
  triggers = {
    machine = module.machine.machine_name
  }

  provisioner "local-exec" {
    command = "podman --remote system connection add tf-${self.id} ssh://core@${module.machine.public_ip}/run/user/1000/podman/podman.sock"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "podman --remote system connection remove tf-${self.id}"
  }
}
