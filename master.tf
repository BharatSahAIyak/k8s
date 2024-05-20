






# data "azurerm_resource_group" "rg" {
#   name = var.resource_group_name
# }

resource "azurerm_public_ip" "lb" {
  name                = "k8s-master-lb-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_lb" "lb" {
  name                = "k8s-master"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "kube-api-frontend-ip"
    public_ip_address_id = azurerm_public_ip.lb.id
  }

}

resource "azurerm_lb_backend_address_pool" "lb_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "k8s-master-pool"
}


resource "azurerm_lb_probe" "lb_probe" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "k8s-master-probe"
  port            = 80
}

resource "azurerm_lb_rule" "lb_rule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "k8s-master-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  disable_outbound_snat          = true
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
  # probe_id                       = azurerm_lb_probe.lb_probe.id
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_pool.id]
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

resource "azurerm_network_interface_backend_address_pool_association" "nic_lb_pool" {
  count                   = var.k8s_master_node_count
  network_interface_id    = module.k8s_master.nic_ids[count.index]
  ip_configuration_name   = "${title("master")}IpConfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_pool.id
}

