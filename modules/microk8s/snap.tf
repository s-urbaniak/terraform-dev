resource "null_resource" "snapd_install" {
  provisioner "remote-exec" {
    inline = [
      "sudo dnf -y install epel-release epel-next-release",
      "sudo dnf -y install snapd",
      "sudo ln -s /var/lib/snapd/snap /snap",
      "sudo systemctl enable --now snapd.socket",
    ]
    on_failure = fail
  }

  connection {
    type = "ssh"
    user = var.ssh_username
    host = var.ssh_ip
  }
}

resource "null_resource" "snapd" {
  depends_on = [
    resource.null_resource.snapd_install,
  ]

  provisioner "remote-exec" {
    inline     = ["sudo shutdown -r +0"]
    on_failure = continue
  }

  provisioner "local-exec" {
    command = "sleep 10"
  }

  connection {
    type = "ssh"
    user = var.ssh_username
    host = var.ssh_ip
  }
}
