output "machine_name" {
  value = module.machine.machine_name
}

output "public_ip" {
  value = module.machine.public_ip
}

output "init" {
    value = module.os.init
}
