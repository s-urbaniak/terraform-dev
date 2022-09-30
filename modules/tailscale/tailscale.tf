resource "null_resource" "tailscale" {
  triggers = {
    "ssh_username" : var.ssh_username,
    "ssh_ip" : var.ssh_ip,
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf -y config-manager --add-repo https://pkgs.tailscale.com/stable/centos/9/tailscale.repo",
      "sudo dnf -y install tailscale",
      "sudo systemctl enable --now tailscaled",
      "sudo tailscale up --authkey ${var.tailscale_key}",
    ]
    on_failure = fail
  }

  provisioner "remote-exec" {
    when   = destroy
    inline = ["sudo tailscale logout"]
  }

  connection {
    type = "ssh"
    user = self.triggers.ssh_username
    host = self.triggers.ssh_ip
  }
}
