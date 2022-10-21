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

data "hcloud_ssh_keys" "all_keys" {}

resource "hcloud_server" "kind" {
  name         = "${var.machine_prefix}-${random_id.machine_suffix.hex}"
  image        = data.hcloud_image.image.name
  server_type  = var.server_type
  location     = var.location
  firewall_ids = [hcloud_firewall.myfirewall.id]

  ssh_keys = data.hcloud_ssh_keys.all_keys.ssh_keys == null ? resource.hcloud_ssh_key.keys.*.id : data.hcloud_ssh_keys.all_keys.ssh_keys.*.name

  depends_on = [
    resource.hcloud_ssh_key.keys,
  ]

  connection {
    type = "ssh"
    user = "root"
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
    protocol  = "udp"
    port      = "51820"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  dynamic "rule" {
    for_each = var.ports
    iterator = port

    content {
      direction = "in"
      protocol  = "tcp"
      port      = tostring(port.value)
      source_ips = [
        "0.0.0.0/0",
        "::/0"
      ]
    }
  }
}
