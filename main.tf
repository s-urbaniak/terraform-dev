provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
  zone    = var.gcp_zone
}

resource "random_id" "machine_suffix" {
  byte_length = 2
}

resource "google_compute_instance" "kind_vm" {
  name         = "${var.machine_prefix}-${random_id.machine_suffix.hex}"
  machine_type = "e2-standard-4"

  boot_disk {
    initialize_params {
      image = var.os_image
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
    inline = [
      "DEBIAN_FRONTEND=noninteractive sudo apt-get update",
      "DEBIAN_FRONTEND=noninteractive sudo apt-get -y install docker.io",
      "curl -OL# ${var.kind_url}",
      "sudo mv kind* /usr/bin/kind",
      "sudo chmod +x /usr/bin/kind",
      "sudo kind create cluster",
      "sudo cp /root/.kube/config kubeconfig",
      "sudo chown ${var.username}:${var.username} kubeconfig",
    ]
  }

  connection {
    type = "ssh"
    user = var.username
    host = self.network_interface[0].access_config[0].nat_ip
  }
}

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.username}@${google_compute_instance.kind_vm.network_interface[0].access_config[0].nat_ip}:~/kubeconfig ."
  }
}

data "external" "kind_port" {
  program = ["sh", "-c", "echo { \\\"port\\\": \\\"$(yq e '.clusters[0].cluster.server' kubeconfig | cut -d':' -f3-)\\\" }"]
}
