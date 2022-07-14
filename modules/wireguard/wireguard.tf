resource "null_resource" "wg_server_keys" {
  provisioner "local-exec" {
    command = "wg genkey | tee wg-server-${self.id}-private.key | wg pubkey > wg-server-${self.id}-public.key"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm wg-server-${self.id}-private.key wg-server-${self.id}-public.key"
  }
}

resource "null_resource" "wg_client_keys" {
  count = length(compact(var.clients)) + 1

  provisioner "local-exec" {
    command = "wg genkey | tee wg-client-${self.id}-private.key | wg pubkey > wg-client-${self.id}-public.key"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm wg-client-${self.id}-private.key wg-client-${self.id}-public.key"
  }
}

resource "null_resource" "wg_preshared_keys" {
  provisioner "local-exec" {
    command = "wg genpsk > wg-preshared-${self.id}.key"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm wg-preshared-${self.id}.key"
  }
}

resource "local_file" "client" {
  count = length(null_resource.wg_client_keys)

  content = templatefile("${path.module}/wg-client.conf", {
    server_key_id    = null_resource.wg_server_keys.id
    client_key_id    = null_resource.wg_client_keys[count.index].id
    preshared_key_id = null_resource.wg_preshared_keys.id
    server_ip        = var.server_ip
    i                = count.index + 2
  })

  filename = "wg-client-${count.index}.conf"
}

resource "null_resource" "server" {
  provisioner "remote-exec" {
    inline = [
      "sudo dnf -y install wireguard-tools",
    ]
  }

  provisioner "file" {
    content = templatefile("${path.module}/wg-server.conf", {
      server_key_id    = null_resource.wg_server_keys.id
      client_key_ids   = [for key in null_resource.wg_client_keys : key.id]
      preshared_key_id = null_resource.wg_preshared_keys.id
    })
    destination = "wg0.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp wg0.conf /etc/wireguard/wg0.conf",
      "sudo systemctl enable --now wg-quick@wg0.service",
    ]
    on_failure = fail
  }

  connection {
    type = "ssh"
    user = var.ssh_username
    host = var.server_ip
  }
}
