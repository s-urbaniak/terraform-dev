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

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.username}@${module.machine.public_ip}:~/kubeconfig ."
  }
}

data "template_file" "tunnel" {
  template = file("${path.module}/tunnel.sh.tpl")
  vars = {
    port      = data.external.kind_port.result["port"]
    username  = var.username
    public_ip = module.machine.public_ip
  }
}

data "external" "kind_port" {
  program = [
    "ssh",
    "-o StrictHostKeyChecking=no",
    "-o UserKnownHostsFile=/dev/null",
    "${var.username}@${module.machine.public_ip}",
    "sudo sh -c 'echo {\\\"port\\\": \\\"$(kind get kubeconfig | grep server | cut -d: -f4)\\\"}'",
  ]
}

resource "local_file" "tunnel" {
  content         = data.template_file.tunnel.rendered
  filename        = "tunnel.sh"
  file_permission = 0777
}
