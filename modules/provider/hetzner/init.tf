resource "null_resource" "disable_selinux" {
  triggers = {
    machine = hcloud_server.kind.ipv4_address
  }

  provisioner "file" {
    destination = "/etc/selinux/config"
    content     = <<EOF
SELINUX=disabled
EOF
  }

  provisioner "remote-exec" {
    inline = [
      "setenforce 0",
    ]
    on_failure = fail
  }

  connection {
    type = "ssh"
    user = "root"
    host = hcloud_server.kind.ipv4_address
  }
}

resource "null_resource" "core" {
  triggers = {
    machine = hcloud_server.kind.ipv4_address
  }

  depends_on = [
    null_resource.disable_selinux,
  ]

  provisioner "file" {
    destination = "/etc/sudoers.d/00-core"
    content     = <<EOF
core ALL=(ALL) NOPASSWD:ALL
EOF
  }

  provisioner "remote-exec" {
    inline = [
      "adduser core",
      "usermod -aG wheel core",
      "usermod -aG adm core",
      "mkdir /home/core/.ssh",
      "chmod 0700 /home/core/.ssh",
      "cp /root/.ssh/authorized_keys /home/core/.ssh/authorized_keys",
      "chmod 0600 /home/core/.ssh/authorized_keys",
      "chown -R core:core /home/core/.ssh",
    ]
    on_failure = fail
  }

  connection {
    type = "ssh"
    user = "root"
    host = hcloud_server.kind.ipv4_address
  }
}
