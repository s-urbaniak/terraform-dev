resource "null_resource" "docker" {
  provisioner "remote-exec" {
    inline = [
      "sudo dnf -y config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo",
      "sudo dnf -y update",
      "sudo dnf -y install docker-ce docker-ce-cli containerd.io",
      "sudo systemctl enable --now docker",
      "sudo usermod -aG docker core",
    ]
    on_failure = fail
  }

  connection {
    type = "ssh"
    user = var.ssh_username
    host = var.ssh_ip
  }
}
