output "master-vm-ips" {
  value = module.k8s_master.vm-ips
}

output "worker-vm-ips" {
  value = module.k8s_worker.vm-ips
}

output "admin-vm-ips" {
  value = module.k8s_admin.vm-ips
}

output "lb-vm-ips" {
  value = module.k8s_lb.vm-ips
}

output "master-private-key" {
  value = module.k8s_master.private_key
  sensitive = true
}
output "admin-private-key" {
  value = module.k8s_admin.private_key
  sensitive = true
}
output "worker-private-key" {
  value = module.k8s_worker.private_key
  sensitive = true
}
output "lb-private-key" {
  value = module.k8s_lb.private_key
  sensitive = true
}