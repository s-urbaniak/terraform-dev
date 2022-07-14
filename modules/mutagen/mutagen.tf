resource "null_resource" "prepare_remote" {
  for_each = toset(var.sync_paths)

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p \"${each.key}\"",
      "sudo chown -R ${var.ssh_username}:${var.ssh_username} \"${each.key}\"",
    ]
    on_failure = fail
  }

  connection {
    type = "ssh"
    user = var.ssh_username
    host = var.ssh_ip
  }
}

resource "null_resource" "mutagen" {
  for_each = toset(var.sync_paths)

  depends_on = [
    null_resource.prepare_remote,
  ]

  provisioner "local-exec" {
    command = "ssh-keygen -R \"${var.ssh_ip}\" || true"
  }

  provisioner "local-exec" {
    command = "yes yes | mutagen sync create --ignore-vcs -i .idea --name=tf-${self.id} \"${each.key}\" ${var.ssh_username}@${var.ssh_ip}:\"${each.key}\""
  }

  provisioner "local-exec" {
    when    = destroy
    command = "mutagen sync terminate tf-${self.id}"
  }
}
