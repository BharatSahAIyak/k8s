


module "k8s_lb" {
  source                  = "./module/vm"
  node_type               = "master"
  number_of_nodes         = 1
  subnet_id               = azurerm_subnet.master.id
  security_group_id       = azurerm_network_security_group.security_group.id
  node_vm_size            = var.k8s_master_node_size
  node_disk_size          = var.k8s_master_disk_size
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
  node_public_ip          = true
}

module "k8s_master" {
  source                  = "./module/vm"
  node_type               = "master"
  number_of_nodes         = var.k8s_master_node_count
  subnet_id               = azurerm_subnet.master.id
  security_group_id       = azurerm_network_security_group.security_group.id
  node_vm_size            = var.k8s_master_node_size
  node_disk_size          = var.k8s_master_disk_size
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
}

