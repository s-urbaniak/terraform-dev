data "google_compute_image" "image" {
  family  = var.image_family
  project = var.image_project
}

resource "google_compute_instance" "kind_vm" {
  name         = "${var.machine_prefix}-${random_id.machine_suffix.hex}"
  machine_type = var.machine_type

  tags = ["${var.machine_prefix}-${random_id.machine_suffix.hex}"]

  boot_disk {
    initialize_params {
      size  = var.disk_size
      image = data.google_compute_image.image.self_link
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "core:${var.ssh_key}"
  }
}

resource "random_id" "machine_suffix" {
  byte_length = 2
}

resource "google_compute_firewall" "default" {
  name    = "${var.machine_prefix}-${random_id.machine_suffix.hex}"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = [for port in var.ports : tostring(port)]
  }

  allow {
    protocol = "udp"
    ports    = ["51820"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.machine_prefix}-${random_id.machine_suffix.hex}"]
}
