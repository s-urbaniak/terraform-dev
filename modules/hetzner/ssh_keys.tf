resource "hcloud_ssh_key" "keys" {
  count      = length(var.ssh_keys)
  name       = var.ssh_keys[count.index].user
  public_key = var.ssh_keys[count.index].publickey
}
