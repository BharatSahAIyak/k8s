


module "k8s_lb" {
  source                  = "./module/vm"
  node_type               = "lb"
  number_of_nodes         = 1
  subnet_id               = azurerm_subnet.master.id
  security_group_id       = azurerm_network_security_group.lb_security_group.id
  node_vm_size            = var.k8s_lb_node_size #todo 
  node_disk_size          = var.k8s_lb_disk_size
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
  node_public_ip          = false
}

module "k8s_master" {
  source                  = "./module/vm"
  node_type               = "master"
  number_of_nodes         = var.k8s_master_node_count
  subnet_id               = azurerm_subnet.master.id
  security_group_id       = azurerm_network_security_group.internal_security_group.id
  node_vm_size            = var.k8s_master_node_size
  node_disk_size          = var.k8s_master_disk_size
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
}

module "k8s_worker" {
  source                  = "./module/vm"
  node_type               = "worker"
  number_of_nodes         = var.k8s_worker_node_count
  subnet_id               = azurerm_subnet.worker.id
  security_group_id       = azurerm_network_security_group.internal_security_group.id
  node_vm_size            = var.k8s_worker_node_size
  node_disk_size          = var.k8s_worker_disk_size
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
}
module "k8s_worker_gpu" {
  source                  = "./module/vm"
  node_type               = "worker-gpu"
  number_of_nodes         = var.k8s_worker_gpu_node_count
  subnet_id               = azurerm_subnet.worker.id
  security_group_id       = azurerm_network_security_group.internal_security_group.id
  node_vm_size            = var.k8s_worker_gpu_node_size
  node_disk_size          = var.k8s_worker_gpu_disk_size
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
}

module "k8s_stateful" {
  source                  = "./module/vm"
  node_type               = "stateful"
  number_of_nodes         = var.k8s_stateful_node_count
  subnet_id               = azurerm_subnet.stateful.id
  security_group_id       = azurerm_network_security_group.internal_security_group.id
  node_vm_size            = var.k8s_stateful_node_size
  node_disk_size          = var.k8s_stateful_disk_size
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
}

