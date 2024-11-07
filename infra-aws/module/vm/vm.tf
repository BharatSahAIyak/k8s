variable "node_type" {}
variable "number_of_nodes" {}
variable "subnet_id" {}
variable "security_group_id" {}
variable "node_vm_size" {}
variable "node_disk_size" {}
variable "vpc_name" {}
variable "node_public_ip" {
  type    = bool
  default = false
}

resource "aws_eip" "public_ip" {
  count = var.node_public_ip ? var.number_of_nodes : 0

  tags = {
    Name = "${var.vpc_name}-${var.node_type}-${count.index}-ip"
  }
}

resource "aws_network_interface" "nic" {
  count       = var.number_of_nodes
  subnet_id   = var.subnet_id
  description = "${var.vpc_name}-${var.node_type}-${count.index}-nic"

  security_groups = [var.security_group_id]  


  tags = {
    Name = "${var.vpc_name}-${var.node_type}-${count.index}-nic"
  }
}

resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "vm_key" {
  key_name   = "${var.vpc_name}-${var.node_type}-key"
  public_key = tls_private_key.rsa_key.public_key_openssh
}

resource "aws_instance" "vm" {
  count         = var.number_of_nodes
  instance_type = var.node_vm_size[count.index]
  ami           = data.aws_ami.ubuntu_ami.id
  key_name      = aws_key_pair.vm_key.key_name
  
  network_interface {
    network_interface_id = aws_network_interface.nic[count.index].id
    device_index         = 0
  }

  root_block_device {
    volume_size           = var.node_disk_size
    volume_type           = "gp2"  
    delete_on_termination = true   
  }

  tags = {
    Name  = "${var.vpc_name}-${var.node_type}-${count.index}"
    roles = "k8s-${var.node_type}"
  }
}



data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["099720109477"] 

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

output "nic_ids" {
  value = aws_network_interface.nic[*].id
}

output "vm-ips" {
  value = { for vm in aws_instance.vm : vm.tags["Name"] => {
    id         = vm.id
    public_ip  = vm.public_ip
    private_ip = vm.private_ip
  } }
}

output "private_key" {
  sensitive = true
  value     = tls_private_key.rsa_key.private_key_openssh
}

#to be used in aws_nat_gateway in networking 
output "public_ip" {
  value = aws_eip.public_ip.*.id  
}