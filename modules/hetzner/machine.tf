
data "hcloud_image" "image" {
  name = var.image
}

resource "hcloud_server" "kind" {
  name        = "${var.machine_prefix}-${random_id.machine_suffix.hex}"
  image       = data.hcloud_image.image.name
  server_type = var.server_type
  location    = var.location

  provisioner "remote-exec" {
    inline = var.provisioner_inline
  }

  ssh_keys = [for key in resource.hcloud_ssh_key.keys : "${key.id}"]

  connection {
    type = "ssh"
    user = var.username
    host = self.ipv4_address
  }
}

resource "random_id" "machine_suffix" {
  byte_length = 2
}

terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}
