# Discover available AWS Availability Zones.
data "aws_availability_zones" "available" {
  state = "available"
}

# Select two distinct Availability Zones.
locals {
  availability_zones = slice(
    data.aws_availability_zones.available.names,
    0,
    2
  )

  public_subnet_cidrs = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  private_subnet_cidrs = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}

# Main VaultBridge VPC.
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vaultbridge-vpc"
  }
}

# Internet Gateway for the public tier.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "vaultbridge-igw"
  }
}

# Create two public subnets in different AZs.
resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "vaultbridge-public-${local.availability_zones[count.index]}"
    Tier = "Public"
  }
}

# Create two private subnets in different AZs.
resource "aws_subnet" "private" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.private_subnet_cidrs[count.index]
  availability_zone       = local.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "vaultbridge-private-${local.availability_zones[count.index]}"
    Tier = "Private"
  }
}

# Public route table.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "vaultbridge-public-rt"
  }
}

# Associate public subnets with the public route table.
resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private route table.
# It has no Internet Gateway or NAT Gateway route.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "vaultbridge-private-rt"
  }
}

# Associate private subnets with the private route table.
resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
