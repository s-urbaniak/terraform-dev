resource "null_resource" "kind_binary" {
  triggers = merge(
    var.triggers,
    {
      "kind_url" : var.kind_url,
      "ssh_username" : var.ssh_username,
      "ssh_ip" : var.ssh_ip,
    }
  )

  provisioner "remote-exec" {
    inline = [
      "curl -OL# ${self.triggers.kind_url}",
      "sudo mv kind-linux* /usr/local/bin/kind",
      "sudo chmod +x /usr/local/bin/kind",
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f /usr/local/bin/kind",
    ]
  }

  connection {
    type = "ssh"
    user = self.triggers.ssh_username
    host = self.triggers.ssh_ip
  }
}

resource "null_resource" "kind_config" {
  count = var.kind_config == "" ? 0 : 1

  triggers = merge(
    var.triggers,
    {
      "ssh_username" : var.ssh_username,
      "ssh_ip" : var.ssh_ip,
      "kind_config" : var.kind_config,
    }
  )

  provisioner "file" {
    content     = var.kind_config
    destination = "kind.yaml"
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "rm -f kind.yaml",
    ]
  }

  connection {
    type = "ssh"
    user = self.triggers.ssh_username
    host = self.triggers.ssh_ip
  }
}


resource "null_resource" "kind_cluster" {
  depends_on = [
    null_resource.kind_binary,
    null_resource.kind_config,
  ]

  triggers = merge(
    var.triggers,
    {
      "ssh_username" : var.ssh_username,
      "ssh_ip" : var.ssh_ip,
      "kind_startup_options" : var.kind_startup_options,
      "kind_config" : var.kind_config,
    }
  )

  provisioner "remote-exec" {
    inline = [
      "sudo KIND_EXPERIMENTAL_PROVIDER=podman /usr/local/bin/kind create cluster ${var.kind_startup_options} ${var.kind_config != "" ? "--config kind.yaml" : ""}",
      "sudo cp /root/.kube/config kubeconfig",
      "sudo chmod a+r kubeconfig",
    ]
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_username}@${var.ssh_ip}:~/kubeconfig ."
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo KIND_EXPERIMENTAL_PROVIDER=podman /usr/local/bin/kind delete cluster",
    ]
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f kubeconfig"
  }

  connection {
    type = "ssh"
    user = self.triggers.ssh_username
    host = self.triggers.ssh_ip
  }
}

resource "local_file" "tunnel" {
  depends_on = [
    null_resource.kind_cluster,
  ]

  content = templatefile("${path.module}/tunnel.sh.tpl", {
    username  = var.ssh_username
    public_ip = var.ssh_ip
  })

  filename        = "tunnel_kind.sh"
  file_permission = 0777
}
