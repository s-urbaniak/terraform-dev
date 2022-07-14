output "public_ip" {
  value = aws_instance.machine.public_ip
}

output "machine_name" {
  value = "${var.machine_prefix}-${random_id.machine_suffix.hex}"
}
