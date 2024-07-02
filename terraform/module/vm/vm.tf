variable "node_type" {}
variable "number_of_nodes" {}
variable "subnet_id" {}
variable "security_group_id" {}
variable "node_vm_size" {}
variable "node_disk_size" {}
variable "resource_group_location" {}
variable "resource_group_name" {}
variable "node_public_ip" {
    type    = bool
    default = false
}

resource "azurerm_public_ip" "public-ip" {
  count = var.node_public_ip ? var.number_of_nodes : 0
  name                = "${var.node_type}-${count.index}-ip"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  allocation_method   = "Static"
}
resource "azurerm_network_interface" "nic" {
  count               = var.number_of_nodes
  name                = "${var.node_type}-${count.index}-nic"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  ip_configuration {
    name                          = "${title(var.node_type)}IpConfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnet_id
    public_ip_address_id = var.node_public_ip ? azurerm_public_ip.public-ip[count.index].id : null
  }
  enable_ip_forwarding      = true
}



resource "azurerm_network_interface_security_group_association" "nic_interface" { 
  count               = var.number_of_nodes
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = var.security_group_id
}

resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "${var.node_type}-${count.index}"
  count                 = var.number_of_nodes
  resource_group_name = var.resource_group_name
  location              = var.resource_group_location
  size = var.node_vm_size
  admin_username = "ubuntu"
  tags = {
    roles = "k8s-${var.node_type}"
  }
#   source_image_id = var.master_image_reference
source_image_reference { #todo remove
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "ubuntu"
    public_key = tls_private_key.rsa_key.public_key_openssh
  }

  os_disk {
    name              = "${var.node_type}disk${count.index}"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    disk_size_gb         = var.node_disk_size
  }

  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
}

output "nic_ids" {
  value = azurerm_network_interface.nic[*].id
}

output "vm-ips" {
  # value = azurerm_linux_virtual_machine.vm.public_ip_address 
  value = {for vm in azurerm_linux_virtual_machine.vm: vm.name => {
    id = vm.id
    public-ip = vm.public_ip_address 
    private-ip = vm.private_ip_address      
          }
    }

}

output "private_key" {
  sensitive = true
  value = tls_private_key.rsa_key.private_key_openssh
}