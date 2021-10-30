resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.username}@${var.public_ip}:~/kubeconfig ."
  }
}

data "template_file" "tunnel" {
  template = file("${path.module}/tunnel.sh.tpl")
  vars = {
    port      = data.external.kind_port.result["port"]
    username  = var.username
    public_ip = var.public_ip
  }
}

data "external" "kind_port" {
  program = [
    "ssh",
    "-o StrictHostKeyChecking=no",
    "-o UserKnownHostsFile=/dev/null",
    "${var.username}@${var.public_ip}",
    "sudo sh -c 'echo {\\\"port\\\": \\\"$(kind get kubeconfig | grep server | cut -d: -f4)\\\"}'",
  ]
}

resource "local_file" "tunnel" {
  content         = data.template_file.tunnel.rendered
  filename        = "tunnel.sh"
  file_permission = 0777
}
