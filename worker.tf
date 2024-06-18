module "k8s_worker" {
  source                  = "./module/vm"
  node_type               = "worker"
  number_of_nodes         = var.k8s_worker_node_count
  subnet_id               = azurerm_subnet.worker.id
  security_group_id       = azurerm_network_security_group.security_group.id
  node_vm_size            = var.k8s_worker_node_size
  node_disk_size          = var.k8s_worker_disk_size
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
}