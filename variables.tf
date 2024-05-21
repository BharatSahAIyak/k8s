variable "resource_group_name" {}
variable "resource_group_location" {}
#network

variable "master_subnet_cidr" {}

variable "admin_subnet_cidr" {}

variable "worker_subnet_cidr" {}

# master 
variable "kube_apiserver_port" {}

variable "k8s_master_node_size" {}
variable "k8s_master_node_count" {}

variable "k8s_master_disk_size" {}


#worker
variable "k8s_worker_node_size" {}

variable "k8s_worker_node_count" {}

variable "k8s_worker_disk_size" {}

#admin
variable "k8s_admin_node_size" {}
variable "k8s_admin_disk_size" {}