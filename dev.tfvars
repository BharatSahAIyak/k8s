resource_group_name     = "k8s-test"
resource_group_location = "Central India"

# each subnet has 30 hosts
master_subnet_cidr = "192.168.0.160/27"

admin_subnet_cidr = "192.168.0.192/27"

worker_subnet_cidr = "192.168.0.224/27"

stateful_subnet_cidr="192.168.0.96/27"
## master 
kube_apiserver_port = "6443"

k8s_master_node_size  = "Standard_D4s_v3" ## 4cpu 	16 GB ram 
k8s_master_node_count = "1"

k8s_master_disk_size = "512"

## worker
k8s_worker_node_size = "Standard_D4s_v3" ## 4cpu 	16 GB ram 

k8s_worker_node_count = "3"

k8s_worker_disk_size = "512"

## admin
k8s_admin_disk_size = "512"
k8s_admin_node_size = "Standard_B2s" 

# LB
k8s_lb_disk_size = "512"
k8s_lb_node_size = "Standard_B2s"

#stateful
k8s_stateful_node_count = "1"
k8s_stateful_node_size = "Standard_F8s_v2" # 8cpu 	16 GB ram 
k8s_stateful_disk_size = "512"



