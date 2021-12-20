terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

data "hcloud_image" "image" {
  name = var.image
}

resource "hcloud_server" "kind" {
  name        = "${var.machine_prefix}-${random_id.machine_suffix.hex}"
  image       = data.hcloud_image.image.name
  server_type = var.server_type
  location    = var.location
  firewall_ids = [hcloud_firewall.myfirewall.id]

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

resource "hcloud_firewall" "myfirewall" {
  name = "${var.machine_prefix}-${random_id.machine_suffix.hex}"
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "udp"
    port      = "51820"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}
