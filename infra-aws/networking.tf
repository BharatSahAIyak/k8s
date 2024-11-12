

resource "aws_vpc" "vn" {
  cidr_block = var.vn_cidr  

  tags = {
    Name = "${var.vpc_name}-vn" 
  }
}

# lb-machine
## contains
### aws_internet_gateway to provide internet connection 
### aws_route_table for public route table
### lb_subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vn.id

  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vn.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.lb_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "lb_subnet" {
  vpc_id                  = aws_vpc.vn.id
  cidr_block              = var.lb_subnet_cidr  
  availability_zone = "ap-south-1b"
  tags = {
    Name = "${var.vpc_name}-lb-subnet"
  }
}



# NAT in the public subnet(lb_subnet)
## - nat_eip(aws_eip resource) specifically for nat_gateway
## - aws_nat_gateway to give unidirectional access of internet to Private Subnets (master, admin, worker, stateful)
resource "aws_eip" "nat_eip" {

  tags = {
    Name = "${var.vpc_name}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id                          # Elastic IP 
  subnet_id     = aws_subnet.lb_subnet.id                     # Set in the public subnet

  depends_on = [aws_internet_gateway.igw] 
}



# Route Table for Private Subnets (master, admin, worker, stateful)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vn.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.vpc_name}-private-route-table"
  }
}



#Private Subnets
resource "aws_subnet" "master_subnet" {
  vpc_id                  = aws_vpc.vn.id
  cidr_block              = var.master_subnet_cidr  
  availability_zone = "ap-south-1b"
  tags = {
    Name = "${var.vpc_name}-master-subnet"
  }
}

resource "aws_subnet" "admin_subnet" {
  vpc_id                  = aws_vpc.vn.id
  cidr_block              = var.admin_subnet_cidr
  availability_zone = "ap-south-1b"
  tags = {
    Name = "${var.vpc_name}-admin-subnet"
  }
}

resource "aws_subnet" "worker_subnet" {
  vpc_id                  = aws_vpc.vn.id
  cidr_block              = var.worker_subnet_cidr  
  availability_zone = "ap-south-1b"
  tags = {
    Name = "${var.vpc_name}-worker-subnet"
  }
}

resource "aws_subnet" "stateful_subnet" {
  vpc_id                  = aws_vpc.vn.id
  cidr_block              = var.stateful_subnet_cidr
  availability_zone = "ap-south-1b"
  tags = {
    Name = "${var.vpc_name}-stateful-subnet"
  }
}



# Associate Private Route Table with each Private Subnet(master, admin, worker, stateful)
resource "aws_route_table_association" "master_subnet_assoc" {
  subnet_id      = aws_subnet.master_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "admin_subnet_assoc" {
  subnet_id      = aws_subnet.admin_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "worker_subnet_assoc" {
  subnet_id      = aws_subnet.worker_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "stateful_subnet_assoc" {
  subnet_id      = aws_subnet.stateful_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}



resource "aws_security_group" "admin_security_group" {
  name        = "${var.vpc_name}-admin-sg"
  description = "Security group for admin access"
  vpc_id      = aws_vpc.vn.id  
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
  vpc_id      = aws_vpc.vn.id
  
}


resource "aws_security_group" "lb_security_group" {
  name        = "${var.vpc_name}-lb-sg"
  description = "Security group for Load Balancer"
  vpc_id      = aws_vpc.vn.id  

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

# #VPN (site-to-site connection)
# resource "aws_vpn_gateway" "vpn_gateway" {
#   vpc_id = aws_vpc.vn.id
# }

# resource "aws_customer_gateway" "customer_gateway" {
#   bgp_asn    = 65000
#   ip_address = var.onsite_IP
#   type       = "ipsec.1"
# }

# resource "aws_vpn_connection" "vpn" {
#   vpn_gateway_id      = aws_vpn_gateway.vpn_gateway.id
#   customer_gateway_id = aws_customer_gateway.customer_gateway.id
#   type                = "ipsec.1"
#   static_routes_only  = true
# }


# #NAT(Network Address Translation) for lb_subnet
# resource "aws_internet_gateway" "internet_gw" {
#   vpc_id = aws_vpc.vn.id

#   tags = {
#     Name = "main"
#   }
# }
 

# resource "aws_nat_gateway" "nat" {
#   allocation_id = module.k8s_lb.public_ip[0]
#   subnet_id     = aws_subnet.master_subnet.id

#   # To ensure proper ordering, it is recommended to add an explicit dependency
#   # on the Internet Gateway for the VPC.
#   depends_on = [aws_internet_gateway.internet_gw]
# }