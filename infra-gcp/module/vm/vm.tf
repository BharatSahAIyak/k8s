# Variables
variable "node_type" {}
variable "number_of_nodes" {}
variable "subnet_id" {}
variable "node_vm_size" {
  type = string
}
variable "node_disk_size" {}
variable "resource_group_name" {}
variable "resource_group_location" {}
variable "target_tags" {}
variable "node_public_ip" {
  type    = bool
  default = false
}

# Create a public IP address if required
resource "google_compute_address" "public_ip" {
  count        = var.node_public_ip ? var.number_of_nodes : 0
  name         = "${var.resource_group_name}-${var.node_type}-${count.index}-ip"
  region       = var.resource_group_location
  address_type = "EXTERNAL"
  project      = var.resource_group_name
}


# Create the instance template for the VM
resource "google_compute_instance" "vm" {
  count               = var.number_of_nodes
  name                = "${var.resource_group_name}-${var.node_type}-${count.index}"
  zone                = var.resource_group_location
  machine_type        = var.node_vm_size
  can_ip_forward      = true
  project             = var.resource_group_name
  network_interface {
    subnetwork    = var.subnet_id
    access_config {
      # Assign a public IP if required
      nat_ip = var.node_public_ip ? google_compute_address.public_ip[count.index].address : null
    }
  }

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20240419"
      size  = var.node_disk_size
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default" # Replace with your network name or variable if you have a custom network
    access_config {
      nat_ip = var.node_public_ip ? google_compute_address.public_ip[count.index].address : null
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${tls_private_key.rsa_key.public_key_openssh}"
  }
}

# Generate a private key
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}


# output "vm_ips" {
#   value = { for vm in google_compute_instance.vm : vm.name => {
#     id         = vm.id
#     public_ip  = vm.
#     private_ip = google_compute_instance.vm[count.index].network_interface[0].network_ip
#     }
#   }
# }

output "private_key" {
  sensitive = true
  value     = tls_private_key.rsa_key.private_key_openssh
}
