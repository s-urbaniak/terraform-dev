resource "null_resource" "microk8s_install" {
  depends_on = [
    resource.null_resource.snapd,
  ]

  provisioner "remote-exec" {
    inline = [
      "sudo snap wait system seed.loaded",
      "sudo snap install microk8s --classic",
      "sudo usermod -a -G microk8s core",
    ]
    on_failure = fail
  }

  connection {
    type = "ssh"
    user = var.ssh_username
    host = var.ssh_ip
  }
}

resource "null_resource" "microk8s" {
  depends_on = [
    resource.null_resource.microk8s_install,
  ]

  provisioner "remote-exec" {
    inline = [
      "microk8s status --wait-ready",
      "microk8s enable dashboard dns registry host-access",
    ]
    on_failure = fail
  }

  connection {
    type = "ssh"
    user = var.ssh_username
    host = var.ssh_ip
  }
}

resource "null_resource" "microk8s_config" {
  depends_on = [
    resource.null_resource.microk8s,
  ]

  triggers = {
    "ssh_username" : var.ssh_username
    "ssh_ip" : var.ssh_ip,
  }


  provisioner "local-exec" {
    command = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null core@${self.triggers.ssh_ip} microk8s config >uk8s_kubeconfig"
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig uk8s_kubeconfig config set-cluster microk8s-cluster --server=https://$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${self.triggers.ssh_username}@${self.triggers.ssh_ip} tailscale ip -4):16443"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f uk8s_kubeconfig"
  }

  connection {
    type = "ssh"
    user = self.triggers.ssh_username
    host = self.triggers.ssh_ip
  }
}
