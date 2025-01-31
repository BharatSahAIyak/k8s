# output "master_vm_ips" {
#   value = module.k8s_master.vm_ips
# }

# output "worker_vm_ips" {
#   value = merge(module.k8s_worker.vm_ips, module.k8s_worker_gpu.vm_ips)
# }

# output "admin_vm_ips" {
#   value = module.k8s_admin.vm_ips
# }

# output "lb_vm_ips" {
#   value = module.k8s_lb.vm_ips
# }

# output "stateful_vm_ips" {
#   value = module.k8s_stateful.vm_ips
# }

output "master_private_key" {
  value     = module.k8s_master.private_key
  sensitive = true
}

output "admin_private_key" {
  value     = module.k8s_admin.private_key
  sensitive = true
}

output "worker_private_key" {
  value     = module.k8s_worker.private_key
  sensitive = true
}

output "worker_gpu_private_key" {
  value     = module.k8s_worker_gpu.private_key
  sensitive = true
}

output "stateful_private_key" {
  value     = module.k8s_stateful.private_key
  sensitive = true
}

output "lb_private_key" {
  value     = module.k8s_lb.private_key
  sensitive = true
}
