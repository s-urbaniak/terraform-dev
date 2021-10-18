output "instance_ip_addr" {
  value = google_compute_instance.kind_vm.network_interface[0].access_config[0].nat_ip
  description = "The public ephemeral IP address of the instance. Use ssh name@IP to connect to it ..."
}

output "ssh_cmd" {
  value = "ssh -N -L ${data.external.kind_port.result["port"]}:127.0.0.1:${data.external.kind_port.result["port"]} ${var.username}@${google_compute_instance.kind_vm.network_interface[0].access_config[0].nat_ip}"
}
