output "init" {
    value = compact(split("\n", data.template_file.init.rendered))
}