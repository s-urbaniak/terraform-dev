resource "null_resource" "remote_podman" {
  triggers = var.triggers

  provisioner "file" {
    content     = file("${path.module}/podman.socket")
    destination = "podman.socket"
  }

  provisioner "remote-exec" {
    inline = [
      // This will ensure the newest podman will be installed via centos stream 8,
      // available via https://copr.fedorainfracloud.org/coprs/rhcontainerbot/podman4/
      "sudo dnf module disable container-tools -y",
      "sudo dnf copr enable rhcontainerbot/podman4  centos-stream-8 -y",
      "sudo dnf -y install podman",
      "sudo cp podman.socket /etc/systemd/system",
      "sudo systemctl enable --now podman",
    ]
  }

  connection {
    type = "ssh"
    user = var.ssh_username
    host = var.ssh_ip
  }
}

resource "null_resource" "local_podman" {
  triggers = {
    remote_podman = null_resource.remote_podman.id
  }

  provisioner "local-exec" {
    command = "podman system connection add tf-${self.id} ssh://${var.ssh_username}@${var.ssh_ip}/run/podman/podman.sock"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "podman system connection remove tf-${self.id}"
  }
}
