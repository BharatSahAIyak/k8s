

resource "aws_vpc" "vn" {
  cidr_block = var.vn_cidr  # VPC CIDR block, e.g., "10.10.0.0/16"

  tags = {
    Name = "${var.vpc_name}-vn"  # Similar to the Azure VNet name
  }
}

resource "aws_subnet" "lb_subnet" {
  vpc_id                  = aws_vpc.vn.id
  cidr_block              = var.lb_subnet_cidr  

  tags = {
    Name = "${var.vpc_name}-lb-subnet"
  }
}

resource "aws_subnet" "master_subnet" {
  vpc_id                  = aws_vpc.vn.id
  cidr_block              = var.master_subnet_cidr  

  tags = {
    Name = "${var.vpc_name}-master-subnet"
  }
}

resource "aws_subnet" "admin_subnet" {
  vpc_id                  = aws_vpc.vn.id
  cidr_block              = var.admin_subnet_cidr

  tags = {
    Name = "${var.vpc_name}-admin-subnet"
  }
}


resource "aws_subnet" "worker_subnet" {
  vpc_id                  = aws_vpc.vn.id
  cidr_block              = var.worker_subnet_cidr  

  tags = {
    Name = "${var.vpc_name}-worker-subnet"
  }
}

resource "aws_subnet" "stateful_subnet" {
  vpc_id                  = aws_vpc.vn.id
  cidr_block              = var.stateful_subnet_cidr

  tags = {
    Name = "${var.vpc_name}-stateful-subnet"
  }
}

resource "aws_security_group" "admin_security_group" {
  name        = "${var.vpc_name}-admin-sg"
  description = "Security group for admin access"
  vpc_id      = aws_vpc.vn.id  # Reference to the VPC where the security group will be created

  // Inbound rule for SSH
  ingress {
    from_port   = 22  # SSH port
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "internal_security_group" {
  name        = "${var.vpc_name}-internal-sg"
  description = "Security group for internal communication"
  vpc_id      = aws_vpc.vn.id  # Reference to the VPC where the security group will be created
}



resource "aws_security_group" "lb_security_group" {
  name        = "${var.vpc_name}-lb-sg"
  description = "Security group for Load Balancer"
  vpc_id      = aws_vpc.vn.id  # Reference to the VPC where the security group will be created

  // Inbound rule to allow HTTP and HTTPS traffic
  ingress {
    from_port   = 80  
    to_port     = 80   
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 443  
    to_port     = 443  
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }
}



