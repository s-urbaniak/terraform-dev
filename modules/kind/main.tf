resource "null_resource" "kind_binary" {
  triggers = {
    "kind_version" : var.kind_version,
    "ssh_username" : var.ssh_username,
    "ssh_ip" : var.ssh_ip,
  }

  provisioner "remote-exec" {
    inline = [
      "curl -OL# https://github.com/kubernetes-sigs/kind/releases/download/${self.triggers.kind_version}/kind-linux-amd64",
      "sudo mv kind-linux* /usr/local/bin/kind",
      "sudo chmod +x /usr/local/bin/kind",
    ]
    on_failure = fail
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo rm -f /usr/local/bin/kind",
    ]
    on_failure = fail
  }

  connection {
    type = "ssh"
    user = self.triggers.ssh_username
    host = self.triggers.ssh_ip
  }
}

resource "null_resource" "kind_config" {
  count = var.kind_config == "" ? 0 : 1

  triggers = {
    "ssh_username" : var.ssh_username,
    "ssh_ip" : var.ssh_ip,
    "kind_config" : var.kind_config,
  }

  provisioner "file" {
    content     = var.kind_config
    destination = "kind.yaml"
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "rm -f kind.yaml",
    ]
    on_failure = fail
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

  triggers = {
    "ssh_username" : var.ssh_username,
    "ssh_ip" : var.ssh_ip,
    "kind_startup_options" : var.kind_startup_options,
    "kind_config" : var.kind_config,
    "use_podman" : var.use_podman,
  }

  provisioner "remote-exec" {
    inline = [
      "sudo /usr/local/bin/kind create cluster ${var.kind_startup_options} ${var.kind_config != "" ? "--config kind.yaml" : ""}",
      "sudo cp /root/.kube/config kubeconfig",
      "sudo chmod a+r kubeconfig",
    ]
    on_failure = fail
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${var.ssh_username}@${var.ssh_ip}:~/kubeconfig ."
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo /usr/local/bin/kind delete cluster",
    ]
    on_failure = fail
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
