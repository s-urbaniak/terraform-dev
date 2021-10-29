output "public_ip" {
  value = module.machine.public_ip
}

output "ssh_cmd" {
  value = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -N -L ${data.external.kind_port.result["port"]}:127.0.0.1:${data.external.kind_port.result["port"]} ${var.username}@${module.machine.public_ip}"
}
