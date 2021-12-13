output "public_ip" {
    value = hcloud_server.kind.ipv4_address
}