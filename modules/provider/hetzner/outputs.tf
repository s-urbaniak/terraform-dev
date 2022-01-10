output "public_ip" {
  value = hcloud_server.kind.ipv4_address
}

output "machine_name" {
  value = "hcloud_server.kind.name"
}
