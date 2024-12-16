


module "k8s_lb" {
  source                  = "./module/vm"
  node_type               = "lb"
  number_of_nodes         = var.k8s_lb_node_count
  subnet_id               = aws_subnet.lb_subnet.id
  security_group_id       = aws_security_group.lb_security_group.id
  node_vm_size            = var.k8s_lb_node_size
  node_disk_size          = var.k8s_lb_disk_size
  vpc_name     = var.vpc_name
  node_public_ip          = true
}



module "k8s_master" {
  source                  = "./module/vm" 
  node_type               = "master"
  number_of_nodes         = var.k8s_master_node_count
  subnet_id               = aws_subnet.master_subnet.id
  security_group_id       = aws_security_group.internal_security_group.id
  node_vm_size            = var.k8s_master_node_size
  node_disk_size          = var.k8s_master_disk_size
  vpc_name     = var.vpc_name
}

# module "k8s_worker" {
#   source                  = "./module/vm"
#   node_type               = "worker"
#   number_of_nodes         = var.k8s_worker_node_count
#   subnet_id               = aws_subnet.worker_subnet.id
#   security_group_id       = aws_security_group.internal_security_group.id
#   node_vm_size            = var.k8s_worker_node_size
#   node_disk_size          = var.k8s_worker_disk_size
#   vpc_name     = var.vpc_name
# }

module "k8s_worker_gpu" {
  source                  = "./module/vm"
  node_type               = "worker-gpu"
  number_of_nodes         = var.k8s_worker_gpu_node_count
  subnet_id               = aws_subnet.worker_subnet.id
  security_group_id       = aws_security_group.internal_security_group.id
  node_vm_size            = var.k8s_worker_gpu_node_size
  node_disk_size          = var.k8s_worker_gpu_disk_size
  vpc_name     = var.vpc_name 
}

module "k8s_stateful" {
  source                  = "./module/vm"
  node_type               = "stateful"
  number_of_nodes         = var.k8s_stateful_node_count
  subnet_id               = aws_subnet.stateful_subnet.id
  security_group_id       = aws_security_group.internal_security_group.id
  node_vm_size            = var.k8s_stateful_node_size
  node_disk_size          = var.k8s_stateful_disk_size
  vpc_name     = var.vpc_name 
}

module "k8s_admin" {
  source                  = "./module/vm"
  node_type               = "admin"
  number_of_nodes         = 1
  subnet_id               = aws_subnet.admin_subnet.id
  security_group_id       = aws_security_group.admin_security_group.id
  node_disk_size          = var.k8s_admin_disk_size
  node_vm_size            = var.k8s_admin_node_size
  node_public_ip          = true
  vpc_name     = var.vpc_name 

}

# For SSH Key Management
resource "aws_secretsmanager_secret" "ssh_private_key_admin" {
  name = "ssh_private-key12-${var.env}-admin"
}

resource "aws_secretsmanager_secret" "ssh_private_key_master" {
  name = "ssh_private-key12-${var.env}-master"
}

resource "aws_secretsmanager_secret" "ssh_private_key_worker_gpu" {
  name = "ssh_private-key12-${var.env}-worker-gpu"
}

resource "aws_secretsmanager_secret" "ssh_private_key_stateful" {
  name = "ssh_private-key12-${var.env}-stateful"
}

resource "aws_secretsmanager_secret" "ssh_private_key_lb" {
  name = "ssh_private-key12-${var.env}-lb"
}

resource "aws_secretsmanager_secret_version" "ssh_private_key_version_admin" {
  secret_id     = aws_secretsmanager_secret.ssh_private_key_admin.id
  secret_string = module.k8s_admin.private_key
}

resource "aws_secretsmanager_secret_version" "ssh_private_key_version_master" {
  secret_id     = aws_secretsmanager_secret.ssh_private_key_master.id
  secret_string = module.k8s_master.private_key
}

resource "aws_secretsmanager_secret_version" "ssh_private_key_version_worker_gpu" {
  secret_id     = aws_secretsmanager_secret.ssh_private_key_worker_gpu.id
  secret_string = module.k8s_worker_gpu.private_key
}

resource "aws_secretsmanager_secret_version" "ssh_private_key_version_stateful" {
  secret_id     = aws_secretsmanager_secret.ssh_private_key_stateful.id
  secret_string = module.k8s_stateful.private_key
}

resource "aws_secretsmanager_secret_version" "ssh_private_key_version_lb" {
  secret_id     = aws_secretsmanager_secret.ssh_private_key_lb.id
  secret_string = module.k8s_lb.private_key
}

# resource "aws_guardduty_detector" "MyDetector" {
#   enable = true

#   datasources {
#     s3_logs {
#       enable = true
#     }
#     kubernetes {
#       audit_logs {
#         enable = false
#       }
#     }
#     malware_protection {
#       scan_ec2_instance_with_findings {
#         ebs_volumes {
#           enable = true
#         }
#       }
#     }
#   }
# }



# resource "null_resource" "setup-admin" {
#   triggers = {
#     always_run = "${timestamp()}"
#   }
#   depends_on = [module.k8s_admin, module.k8s_lb, module.k8s_master, module.k8s_stateful, module.k8s_worker_gpu]
#   connection {
#     type        = "ssh"
#     user        = "ubuntu"
#     private_key = module.k8s_admin.private_key
#     host        = module.k8s_admin.vm-ips["${var.vpc_name}-admin-0"].public_ip
#   }
#   # provisioner "file" {
#   #   content = templatefile("${path.module}/inventory.ini.tftpl",
#   #     { master_nodes = [for vm, ips in module.k8s_master.vm-ips : { name = vm, ip = ips.private_ip }],
#   #       worker_nodes = [for vm, ips in module.k8s_worker.vm-ips : { name = vm, ip = ips.private_ip }],
#   #       worker_gpu_nodes = [for vm, ips in module.k8s_worker_gpu.vm-ips : { name = vm, ip = ips.private_ip }],
#   #   })
#   #   destination = "/home/ubuntu/inventory.ini"
#   # }

#   provisioner "file" {
#     content     = module.k8s_master.private_key
#     destination = "/home/ubuntu/.ssh/master.pem"
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