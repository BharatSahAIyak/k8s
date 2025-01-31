### `variables.tf`

variable "resource_group_name" {}
variable "resource_group_location" {}

# Network
variable "vn_cidr" {}

variable "master_subnet_cidr" {}

variable "admin_subnet_cidr" {}

variable "worker_subnet_cidr" {}

variable "stateful_subnet_cidr" {}

# Master
variable "kube_apiserver_port" {}

variable "k8s_master_node_size" {}

variable "k8s_master_node_count" {}

variable "k8s_master_disk_size" {}

# Worker
variable "k8s_worker_node_size" {}

variable "k8s_worker_node_count" {}

variable "k8s_worker_disk_size" {}

variable "k8s_worker_gpu_node_size" {}

variable "k8s_worker_gpu_node_count" {}

variable "k8s_worker_gpu_disk_size" {}

# Admin
variable "k8s_admin_node_size" {}

variable "k8s_admin_disk_size" {}

# Load Balancer
variable "k8s_lb_node_size" {}

variable "k8s_lb_disk_size" {}

variable "k8s_lb_node_count" {}

# Stateful
variable "k8s_stateful_node_count" {}

variable "k8s_stateful_node_size" {}

variable "k8s_stateful_disk_size" {}
