data "google_compute_image" "image" {
  family  = var.image_family
  project = var.image_project
}

resource "google_compute_instance" "kind_vm" {
  name         = "${var.machine_prefix}-${random_id.machine_suffix.hex}"
  machine_type = "${var.machine_type}"

  boot_disk {
    initialize_params {
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
    ssh-keys = join("\n", [for key in var.ssh_keys : "${key.user}:${key.publickey}"])
  }

  provisioner "remote-exec" {
    inline = var.provisioner_inline
  }

  connection {
    type = "ssh"
    user = var.username
    host = self.network_interface[0].access_config[0].nat_ip
  }
}

resource "random_id" "machine_suffix" {
  byte_length = 2
}