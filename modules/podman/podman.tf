resource "null_resource" "remote_podman" {
  provisioner "file" {
    content     = file("${path.module}/podman.socket")
    destination = "podman.socket"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf -y install podman libseccomp",
      "sudo cp podman.socket /etc/systemd/system",
      "sudo systemctl enable --now podman",
      "sudo systemctl start podman.socket",
      "systemctl --user start podman.socket",
    ]
    on_failure = fail
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
    command = "podman system connection add tf-${self.id} ssh://${var.ssh_username}@${var.ssh_ip}/run/user/1000/podman/podman.sock"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "podman system connection remove tf-${self.id}"
  }
}
