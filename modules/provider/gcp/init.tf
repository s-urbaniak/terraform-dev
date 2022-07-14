resource "null_resource" "disable_selinux" {
  triggers = {
    machine = google_compute_instance.kind_vm.network_interface[0].access_config[0].nat_ip
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
    user = "core"
    host = google_compute_instance.kind_vm.network_interface[0].access_config[0].nat_ip
  }
}
