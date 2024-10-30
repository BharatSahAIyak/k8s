module "k8s_lb" {
  source                  = "./module/vm"
  node_type               = "lb"
  number_of_nodes         = var.k8s_lb_node_count
  subnet_id               = google_compute_subnetwork.master.id
  node_vm_size            = var.k8s_lb_node_size
  node_disk_size          = var.k8s_lb_disk_size
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
  target_tags             = ["k8s-lb"]  # Add tag for load balancer
}

module "k8s_master" {
  source                  = "./module/vm"
  node_type               = "master"
  number_of_nodes         = var.k8s_master_node_count
  subnet_id               = google_compute_subnetwork.master.id
  node_vm_size            = var.k8s_master_node_size
  node_disk_size          = var.k8s_master_disk_size
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
  target_tags             = ["k8s-master"]  # Add tag for master
}

module "k8s_worker" {
  source                  = "./module/vm"
  node_type               = "worker"
  number_of_nodes         = var.k8s_worker_node_count
  subnet_id               = google_compute_subnetwork.worker.id
  node_vm_size            = var.k8s_worker_node_size
  node_disk_size          = var.k8s_worker_disk_size
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
  target_tags             = ["k8s-master"] 
}

module "k8s_worker_gpu" {
  source                  = "./module/vm"
  node_type               = "worker-gpu"
  number_of_nodes         = var.k8s_worker_gpu_node_count
  subnet_id               = google_compute_subnetwork.worker.id
  node_vm_size            = var.k8s_worker_gpu_node_size
  node_disk_size          = var.k8s_worker_gpu_disk_size
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
  target_tags             = ["k8s-master"]  
}

module "k8s_stateful" {
  source                  = "./module/vm"
  node_type               = "stateful"
  number_of_nodes         = var.k8s_stateful_node_count
  subnet_id               = google_compute_subnetwork.stateful.id
  node_vm_size            = var.k8s_stateful_node_size
  node_disk_size          = var.k8s_stateful_disk_size
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
  target_tags             = ["k8s-master"] 
}

module "k8s_admin" {
  source                  = "./module/vm"
  node_type               = "admin"
  number_of_nodes         = 1
  subnet_id               = google_compute_subnetwork.master.id
  node_vm_size            = var.k8s_admin_node_size
  node_disk_size          = var.k8s_admin_disk_size
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
  node_public_ip          = true
  target_tags             = ["k8s-admin"]  # Add tag for admin
}

resource "local_file" "ssh_private_key" {
  filename = "${path.module}/admin.pem"
  content  = module.k8s_admin.private_key
}

# resource "null_resource" "setup-admin" {
#   triggers = {
#     always_run = "${timestamp()}"
#   }
#   depends_on = [module.k8s_admin, module.k8s_lb, module.k8s_master, module.k8s_stateful, module.k8s_worker, module.k8s_worker_gpu]

#   provisioner "remote-exec" {
#     inline = [
#       "echo 'Setting up Kubernetes environment...'",
#     ]
#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = module.k8s_admin.private_key
#       host        = module.k8s_admin.vm-ips["${var.resource_group_name}-admin-0"].public-ip
#     }
#   }

#   provisioner "file" {
#     content = templatefile("${path.module}/inventory.ini.tftpl",
#       {
#         master_nodes = [for vm, ips in module.k8s_master.vm-ips : { name = vm, ip = ips.private_ip }],
#         worker_nodes = [for vm, ips in module.k8s_worker.vm-ips : { name = vm, ip = ips.private_ip }],
#         worker_gpu_nodes = [for vm, ips in module.k8s_worker_gpu.vm-ips : { name = vm, ip = ips.private_ip }],
#       })
#     destination = "/home/ubuntu/inventory.ini"
#   }

#   provisioner "file" {
#     content     = module.k8s_master.private_key
#     destination = "/home/ubuntu/.ssh/master.pem"
#   }

#   provisioner "file" {
#     content     = module.k8s_worker.private_key
#     destination = "/home/ubuntu/.ssh/worker.pem"
#   }

#   provisioner "file" {
#     content     = module.k8s_worker_gpu.private_key
#     destination = "/home/ubuntu/.ssh/worker_gpu.pem"
#   }

#   provisioner "file" {
#     content     = module.k8s_lb.private_key
#     destination = "/home/ubuntu/.ssh/lb.pem"
#   }

#   provisioner "file" {
#     content     = module.k8s_stateful.private_key
#     destination = "/home/ubuntu/.ssh/stateful.pem"
#   }
# }
