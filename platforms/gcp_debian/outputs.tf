output "public_ip" {
  value = module.machine.public_ip
}

output "ssh_cmd" {
  value = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -N -L ${var.username}@${module.machine.public_ip}"
}
