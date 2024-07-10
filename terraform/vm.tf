


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
  node_public_ip          = true
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

module "k8s_admin" {
  source                  = "./module/vm"
  node_type               = "admin"
  number_of_nodes         = "1"
  subnet_id               = azurerm_subnet.master.id
  security_group_id       = azurerm_network_security_group.admin_security_group.id
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
  depends_on = [module.k8s_admin, module.k8s_lb, module.k8s_master, module.k8s_stateful, module.k8s_worker, module.k8s_worker_gpu]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = module.k8s_admin.private_key
    host        = module.k8s_admin.vm-ips["${var.resource_group_name}-admin-0"].public-ip
  }
  provisioner "file" {
    content = templatefile("${path.module}/inventory.ini.tftpl",
      { master_nodes = [for vm, ips in module.k8s_master.vm-ips : { name = vm, ip = ips.private-ip }],
        worker_nodes = [for vm, ips in merge(module.k8s_worker.vm-ips, module.k8s_worker_gpu.vm-ips) : { name = vm, ip = ips.private-ip }],
    })
    destination = "/home/ubuntu/inventory.ini"
  }

  provisioner "file" {
    content     = module.k8s_master.private_key
    destination = "/home/ubuntu/.ssh/master.pem"
  }
  provisioner "file" {
    content     = module.k8s_worker.private_key
    destination = "/home/ubuntu/.ssh/worker.pem"
  }
  provisioner "file" {
    content     = module.k8s_worker_gpu.private_key
    destination = "/home/ubuntu/.ssh/worker_gpu.pem"
  }
  provisioner "file" {
    content     = module.k8s_lb.private_key
    destination = "/home/ubuntu/.ssh/lb.pem"
  }
  provisioner "file" {
    content     = module.k8s_stateful.private_key
    destination = "/home/ubuntu/.ssh/stateful.pem"
  }
}

