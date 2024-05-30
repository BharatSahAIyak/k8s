module "k8s_admin" {
  source                  = "./module/vm"
  node_type               = "admin"
  number_of_nodes         = "1"
  subnet_id               = azurerm_subnet.master.id
  security_group_id       = azurerm_network_security_group.security_group.id
  node_vm_size            = var.k8s_admin_node_size
  node_disk_size          = var.k8s_admin_disk_size
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
}