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