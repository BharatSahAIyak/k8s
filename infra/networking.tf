

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_virtual_network" "vn" {
  name                = "${var.resource_group_name}-vn"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vn_cidr]
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_subnet" "master" {
  name                 = "${var.resource_group_name}-master-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = [var.master_subnet_cidr]
}

resource "azurerm_subnet" "admin" {
  name                 = "${var.resource_group_name}-admin-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = [var.admin_subnet_cidr]
}

resource "azurerm_subnet" "worker" {
  name                 = "${var.resource_group_name}-worker-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = [var.worker_subnet_cidr]
}

resource "azurerm_subnet" "stateful" {
  name                 = "${var.resource_group_name}-stateful-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = [var.stateful_subnet_cidr]
}

resource "azurerm_network_security_group" "admin_security_group" {
  name                = "${var.resource_group_name}-admin-sg"
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
}

resource "azurerm_network_security_group" "internal_security_group" {
  name                = "${var.resource_group_name}-internal-sg"
  resource_group_name = azurerm_resource_group.rg.name

  location = azurerm_resource_group.rg.location
}

resource "azurerm_network_security_group" "lb_security_group" {
  name                = "${var.resource_group_name}-lb-sg"
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