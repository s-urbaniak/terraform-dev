resource "null_resource" "kubeconfig" {
  triggers = var.triggers

  provisioner "remote-exec" {
    inline = [
      "curl -OL# ${var.kind_url}",
      "sudo mv kind* /usr/local/bin/kind",
      "sudo chmod +x /usr/local/bin/kind",
      "sudo KIND_EXPERIMENTAL_PROVIDER=podman /usr/local/bin/kind create cluster",
      "sudo cp /root/.kube/config kubeconfig",
      "sudo chmod a+r kubeconfig",
    ]
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_username}@${var.ssh_ip}:~/kubeconfig ."
  }

  connection {
    type = "ssh"
    user = var.ssh_username
    host = var.ssh_ip
  }
}

data "external" "kind_port" {
  program = [
    "ssh",
    "-o StrictHostKeyChecking=no",
    "-o UserKnownHostsFile=/dev/null",
    "${var.ssh_username}@${var.ssh_ip}",
    "sudo KIND_EXPERIMENTAL_PROVIDER=podman sh -c 'echo {\\\"port\\\": \\\"$(/usr/local/bin/kind get kubeconfig | grep server | cut -d: -f4)\\\"}'",
  ]
}

resource "local_file" "tunnel" {
  depends_on = [
    null_resource.kubeconfig,
  ]

  content = templatefile("${path.module}/tunnel.sh.tpl", {
    port      = data.external.kind_port.result["port"]
    username  = var.ssh_username
    public_ip = var.ssh_ip
  })
  filename        = "tunnel_kind.sh"
  file_permission = 0777
}
