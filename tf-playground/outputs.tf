# ---------------------------------------------
#    Main Module Output return variables
# ---------------------------------------------

output "cp-node01_public_ip" {
  value = join("",["ssh -i ", var.ssh_private_key_path," ubuntu@", module.cp-node01.public_ip])
}

output "wk-node01_public_ip" {
  value = join("",["ssh -i ", var.ssh_private_key_path," ubuntu@", module.wk-node01.public_ip])
}

output "wk-node02_public_ip" {
  value = join("",["ssh -i ", var.ssh_private_key_path," ubuntu@", module.wk-node02.public_ip])
}