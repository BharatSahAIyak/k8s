variable "vpc_name" {}
variable "resource_group_location" {}

#network
variable "vn_cidr" {}

variable "master_subnet_cidr" {}

variable "admin_subnet_cidr" {}

variable "worker_subnet_cidr" {}
variable "stateful_subnet_cidr" {}

#master
variable "kube_apiserver_port" {}

variable "k8s_master_node_size" {}
variable "k8s_master_node_count" {}

variable "k8s_master_disk_size" {}

#worker
variable "k8s_worker_node_size" {}
variable "k8s_worker_node_count" {}
variable "k8s_worker_disk_size" {}

variable "k8s_worker_gpu_node_size" {}
variable "k8s_worker_gpu_node_count" {}
variable "k8s_worker_gpu_disk_size" {}

#admin
variable "k8s_admin_node_size" {}
variable "k8s_admin_disk_size" {}

#lb
variable "k8s_lb_node_size" {}
variable "k8s_lb_disk_size" {}
variable "k8s_lb_node_count" {}


#stateful
variable "k8s_stateful_node_count" {}
variable "k8s_stateful_node_size" {}
variable "k8s_stateful_disk_size" {}