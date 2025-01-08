

resource "aws_vpc" "vn" {
  cidr_block = var.vn_cidr  

  tags = {
    Name = "${var.vpc_name}-vn" 
  }
}

# lb-machine <starts> #
## aws_internet_gateway to provide internet connection 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vn.id

  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}

## aws_route_table for public route table
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

## lb_subnet
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.lb_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

## lb_subnet
resource "aws_subnet" "lb_subnet" {
  vpc_id                  = aws_vpc.vn.id
  cidr_block              = var.lb_subnet_cidr  
  availability_zone = "ap-south-1b"
  tags = {
    Name = "${var.vpc_name}-lb-subnet"
  }
}
# lb-machine <ends> #


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



# Private Subnets
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


# Security Group for admin node
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


# WAF(Web Application Firewall) for regional sope 
## Using AWS_Managed_Rules 
resource "aws_wafv2_web_acl" "WAF" {
  name        = "aws-managed-rule-waf"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "rule-1"
    priority = 1

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "SizeRestrictions_QUERYSTRING"
        }

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "NoUserAgent_HEADER"
        }

        # scope_down_statement {
        #   geo_match_statement {
        #     country_codes = ["US", "NL"]
        #   }
        # }
      }
    }

    # rule specific visibility config
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "friendly-rule-metric-name"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 10


    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            count {}
          }

          name = "SizeRestrictions_QUERYSTRING"
        }

      }
    
    }

    override_action {
      count {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "friendly-rule-metric-name"
      sampled_requests_enabled   = false
    }
  }


  tags = {
    Tag1 = "${var.vpc_name}"
  }

  # token_domains = ["mywebsite.com", "myotherwebsite.com"]

  # global ACL level visiblity config
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "friendly-metric-name"
    sampled_requests_enabled   = true
  }
}
