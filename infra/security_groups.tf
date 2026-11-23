
# ==========================================
# EC2 SECURITY GROUP
# ==========================================

resource "aws_security_group" "ec2" {
  name        = "vaultbridge-ec2-sg"
  description = "Security group for VaultBridge application server"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "vaultbridge-ec2-sg"
  }
}

# SSH: Allow access only from your public IP.
resource "aws_vpc_security_group_ingress_rule" "ec2_ssh" {
  security_group_id = aws_security_group.ec2.id

  description = "SSH access restricted to administrator IP"
  cidr_ipv4   = var.my_ip_cidr
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

# HTTP: Allow web traffic from anywhere.
resource "aws_vpc_security_group_ingress_rule" "ec2_http" {
  security_group_id = aws_security_group.ec2.id

  description = "Public HTTP traffic"
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

# EC2: Allow all outbound traffic as required by the brief.
resource "aws_vpc_security_group_egress_rule" "ec2_all_egress" {
  security_group_id = aws_security_group.ec2.id

  description = "Allow all outbound traffic"
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


# ==========================================
# RDS SECURITY GROUP
# ==========================================

resource "aws_security_group" "rds" {
  name        = "vaultbridge-rds-sg"
  description = "Security group for VaultBridge PostgreSQL database"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "vaultbridge-rds-sg"
  }
}

# PostgreSQL: Only the EC2 security group can connect.
resource "aws_vpc_security_group_ingress_rule" "rds_postgres" {
  security_group_id = aws_security_group.rds.id

  description                  = "PostgreSQL access from VaultBridge EC2 only"
  referenced_security_group_id = aws_security_group.ec2.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}
