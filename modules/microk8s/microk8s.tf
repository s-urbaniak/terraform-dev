resource "null_resource" "microk8s_install" {
  depends_on = [
    resource.null_resource.snapd,
  ]

  provisioner "remote-exec" {
    inline = [
      "sudo snap wait system seed.loaded",
      "sudo snap install microk8s --classic --channel=${var.channel}",
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
    inline     = concat(["microk8s status --wait-ready"], formatlist("microk8s enable %s", var.addons))
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
    "kubeconfig_filename" : var.kubeconfig_filename,
  }

  provisioner "local-exec" {
    command = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null core@${self.triggers.ssh_ip} microk8s config >${self.triggers.kubeconfig_filename}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ${self.triggers.kubeconfig_filename}"
  }

  connection {
    type = "ssh"
    user = self.triggers.ssh_username
    host = self.triggers.ssh_ip
  }
}
