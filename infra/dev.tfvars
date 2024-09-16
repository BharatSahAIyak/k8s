resource_group_name     = "bhasai-dev"
resource_group_location = "Central India"

vn_cidr = "10.10.0.0/16"

master_subnet_cidr = "10.10.1.0/24"

admin_subnet_cidr = "10.10.2.0/24"

worker_subnet_cidr = "10.10.3.0/24"

stateful_subnet_cidr = "10.10.4.0/24"
kube_apiserver_port = "6443"

k8s_master_node_size  = ["Standard_D4s_v3"]
k8s_master_node_count = "1"
k8s_master_disk_size  = "256"

k8s_worker_node_size  = ["Standard_D4s_v3", "Standard_D4s_v3", "Standard_D4s_v3"]
k8s_worker_node_count = "3"
k8s_worker_disk_size  = "128"

k8s_worker_gpu_node_size  = ["Standard_NC4as_T4_v3", "Standard_NC4as_T4_v3", "Standard_NC4as_T4_v3"]
k8s_worker_gpu_node_count = "3"
k8s_worker_gpu_disk_size  = "256"

k8s_admin_disk_size = "128"
k8s_admin_node_size = ["Standard_D4s_v3"]

k8s_lb_disk_size = "128"
k8s_lb_node_size = ["Standard_D4s_v3", "Standard_D4s_v3"]
k8s_lb_node_count = 2

k8s_stateful_node_count = "3"
k8s_stateful_node_size  = ["Standard_D4s_v3", "Standard_E4bds_v5", "Standard_E4bds_v5"] ## 4cpu 	16 GB ram 
k8s_stateful_disk_size  = "512"



