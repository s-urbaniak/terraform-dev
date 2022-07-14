resource "null_resource" "disable_selinux" {
  triggers = {
    machine = aws_instance.machine.public_ip
  }

  provisioner "file" {
    destination = "selinux-config"
    content     = <<EOF
SELINUX=disabled
EOF
  }

  provisioner "remote-exec" {
    inline = [
      "sudo setenforce 0",
      "sudo cp selinux-config /etc/selinux/config",
    ]
    on_failure = fail
  }

  connection {
    type = "ssh"
    user = "centos"
    host = aws_instance.machine.public_ip
  }
}

resource "null_resource" "core" {
  depends_on = [
    null_resource.disable_selinux,
  ]

  triggers = {
    machine = aws_instance.machine.public_ip
  }

  provisioner "file" {
    destination = "00-core"
    content     = <<EOF
core ALL=(ALL) NOPASSWD:ALL
EOF
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp 00-core /etc/sudoers.d/00-core",
      "sudo adduser core",
      "sudo usermod -aG wheel core",
      "sudo usermod -aG adm core",
      "sudo mkdir /home/core/.ssh",
      "sudo chmod 0700 /home/core/.ssh",
      "sudo cp /home/centos/.ssh/authorized_keys /home/core/.ssh/authorized_keys",
      "sudo chmod 0600 /home/core/.ssh/authorized_keys",
      "sudo chown -R core:core /home/core/.ssh",
    ]
    on_failure = fail
  }

  connection {
    type = "ssh"
    user = "centos"
    host = aws_instance.machine.public_ip
  }
}
