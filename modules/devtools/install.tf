resource "null_resource" "remote_podman" {
  triggers = var.triggers

  provisioner "remote-exec" {
    inline = [
      "sudo dnf -y groupinstall \"Development Tools\"",
      "sudo dnf -y install golang jq",
    ]
    on_failure = fail
  }

  connection {
    type = "ssh"
    user = var.ssh_username
    host = var.ssh_ip
  }
}
