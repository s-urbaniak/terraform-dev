resource "null_resource" "podman" {
  triggers = var.triggers

  provisioner "local-exec" {
    command = "podman --remote system connection add tf-${self.id} ssh://${var.username}@${var.remote_ip}${var.podman_socket}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "podman --remote system connection remove tf-${self.id}"
  }
}
