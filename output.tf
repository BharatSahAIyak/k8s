output "master-public-ips" {
  value = module.k8s_master.public-ips
}

output "worker-public-ips" {
  value = module.k8s_worker.public-ips

}

output "load-balancer" {
  value = {
    ip = azurerm_public_ip.lb.ip_address
  }
}