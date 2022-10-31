resource "hcloud_ssh_key" "keys" {
  count      = var.ssh_key == "" ? 0 : 1
  name       = "${var.machine_prefix}-${random_id.machine_suffix.hex}"
  public_key = var.ssh_key
}
