data "template_file" "init" {
  template = file("${path.module}/init.tpl")
  vars = {
    kind_url = var.kind_url
    username = var.username
  }
}
