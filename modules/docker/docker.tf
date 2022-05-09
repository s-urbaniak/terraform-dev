resource "null_resource" "docker" {
  triggers = var.triggers

  provisioner "remote-exec" {
    inline = [
      "sudo dnf -y config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo",
      "sudo dnf -y update",
      "sudo dnf -y install docker-ce docker-ce-cli containerd.io",
      "sudo systemctl enable --now docker",
      "sudo usermod -aG docker core",
    ]
  }

  connection {
    type = "ssh"
    user = var.ssh_username
    host = var.ssh_ip
  }
}
