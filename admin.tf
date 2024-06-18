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
  node_public_ip          = true
}

resource "local_sensitive_file" "ssh_private_key" {
  filename = "${path.module}/admin.pem"
  content  = module.k8s_admin.private_key
}

resource "null_resource" "setup-admin" {
  triggers = {
    always_run = "${timestamp()}"
  }
  depends_on = [ module.k8s_admin,module.k8s_lb,module.k8s_master,module.k8s_stateful,module.k8s_worker ]
    connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = module.k8s_admin.private_key
    host     = module.k8s_admin.vm-ips["admin-0"].public-ip
  }
  provisioner "file" {
    content = templatefile("${path.module}/inventory.ini.tftpl",
  {master_nodes = [for vm , ips in module.k8s_master.vm-ips: {name = vm, ip=ips.private-ip}],
  worker_nodes = [for vm , ips in module.k8s_worker.vm-ips: {name = vm, ip=ips.private-ip}],
  })
  destination = "/home/ubuntu/inventory.ini"
  }

  provisioner "file" {
    content = module.k8s_master.private_key
    destination = "/home/ubuntu/.ssh/master.pem"
  }
   provisioner "file" {
    content = module.k8s_worker.private_key
    destination = "/home/ubuntu/.ssh/worker.pem"
  } 
  provisioner "file" {
    content = module.k8s_lb.private_key
    destination = "/home/ubuntu/.ssh/lb.pem"
  }
  provisioner "file" {
source = "ansible/kubectl_setup.yml"
destination = "/home/ubuntu/kubectl_setup.yml"
}


}