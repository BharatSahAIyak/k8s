

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "vpc" {
  name                = "k8s-vpc"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vpc_subnet_cidr]
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "master" {
  name                 = "master-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vpc.name
  address_prefixes     = [var.master_subnet_cidr]
}

resource "azurerm_subnet" "admin" {
  name                 = "admin-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vpc.name
  address_prefixes     = [var.admin_subnet_cidr]
}

resource "azurerm_subnet" "worker" {
  name                 = "worker-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vpc.name
  address_prefixes     = [var.worker_subnet_cidr]
}

resource "azurerm_subnet" "stateful" {
  name                 = "stateful-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vpc.name
  address_prefixes     = [var.stateful_subnet_cidr]
}

resource "azurerm_network_security_group" "security_group" {
  name                = "k8s-sg"
  resource_group_name = azurerm_resource_group.rg.name

  location = azurerm_resource_group.rg.location

  security_rule {
    name                       = "ssh"
    description                = "Allow SSH"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    access                     = "Allow"
    priority                   = 100
    direction                  = "Inbound"
  }

  security_rule {
    name                       = "kube-api"
    description                = "Allow secure kube-api"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.kube_apiserver_port
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    access                     = "Allow"
    priority                   = 101
    direction                  = "Inbound"
  }
}

resource "azurerm_network_security_group" "lb_security_group" {
  name                = "k8s-lb-sg"
  resource_group_name = azurerm_resource_group.rg.name

  location = azurerm_resource_group.rg.location


  security_rule {
    name                       = "https"
    description                = "Allow http/https"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = ["80","443"]
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    access                     = "Allow"
    priority                   = 101
    direction                  = "Inbound"
  }
}