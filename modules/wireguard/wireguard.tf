resource "null_resource" "wg-keys" {
  for_each = toset(["client", "server"])
  triggers = var.triggers

  provisioner "local-exec" {
    command = "wg genkey | tee ${self.id}-private.key | wg pubkey > ${self.id}-public.key"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm ${self.id}-private.key ${self.id}-public.key"
  }
}

resource "null_resource" "wg-preshared-key" {
  triggers = var.triggers

  provisioner "local-exec" {
    command = "wg genpsk > ${self.id}.key"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm ${self.id}.key"
  }
}

resource "local_file" "client" {
  content  = data.template_file.wg_client.rendered
  filename = "wg0.conf"
}

resource "null_resource" "server" {
  provisioner "file" {
    content     = data.template_file.wg_server.rendered
    destination = "wg0.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp wg0.conf /etc/wireguard/wg0.conf",
      "systemctl enable wg-quick@wg0.service",
      "wg-quick up wg0"
    ]
  }

  connection {
    type = "ssh"
    user = var.ssh_username
    host = var.server_ip
  }
}

data "template_file" "wg_server" {
  template = file("${path.module}/wg-server.conf")

  vars = {
    server_private_key = file("${null_resource.wg-keys["server"].id}-private.key")
    client_public_key  = file("${null_resource.wg-keys["client"].id}-public.key")
    preshared_key      = file("${null_resource.wg-preshared-key.id}.key")
  }
}

data "template_file" "wg_client" {
  template = file("${path.module}/wg-client.conf")

  vars = {
    client_private_key = file("${null_resource.wg-keys["client"].id}-public.key")
    server_public_key  = file("${null_resource.wg-keys["server"].id}-public.key")
    preshared_key      = file("${null_resource.wg-preshared-key.id}.key")
    server_ip          = "${var.server_ip}"
  }
}
