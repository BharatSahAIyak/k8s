vpc_name     = "kumbh-sahaiyak-production"
resource_group_location = "ap-south-1"
env = "production"

vn_cidr = "10.10.0.0/16"

master_subnet_cidr = "10.10.1.0/24"

admin_subnet_cidr = "10.10.2.0/24"

worker_subnet_cidr = "10.10.3.0/24"

lb_subnet_cidr = "10.10.5.0/24"

stateful_subnet_cidr = "10.10.4.0/24"
kube_apiserver_port = "6443"

k8s_master_node_size  = ["c6a.4xlarge", "g5.4xlarge"]
k8s_master_node_count = "2"
k8s_master_disk_size  = ["256","256"]

k8s_worker_node_size  = [""]
k8s_worker_node_count = "0"
k8s_worker_disk_size  = ""

k8s_worker_gpu_node_size  = ["g5.4xlarge","g5.4xlarge"]
k8s_worker_gpu_node_count = "2"
k8s_worker_gpu_disk_size  = ["256","256"]

k8s_admin_disk_size = ["50"]
k8s_admin_node_size = ["c6a.xlarge"]

k8s_lb_disk_size = ["128","128"]
k8s_lb_node_size = ["m6a.4xlarge","m6a.4xlarge"]
k8s_lb_node_count = "2"

k8s_stateful_node_count = "4"
k8s_stateful_node_size  = ["m6a.4xlarge", "m6a.4xlarge", "g5.4xlarge", "g5.4xlarge"] ## 4cpu 	16 GB ram 
k8s_stateful_disk_size  = ["256","256","256","256"]

#vpn eg: "172.0.0.1"
onsite_IP = ""


