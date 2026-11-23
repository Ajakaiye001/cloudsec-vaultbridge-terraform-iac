output "vpc_id" {
  description = "VaultBridge VPC ID."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "VaultBridge VPC CIDR block."
  value       = aws_vpc.main.cidr_block
}

output "availability_zones" {
  description = "Availability Zones selected for the network."
  value       = local.availability_zones
}

output "public_subnet_ids" {
  description = "IDs of the two public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the two private subnets."
  value       = aws_subnet.private[*].id
}
output "ec2_public_ip" {
  description = "Static public IP of the VaultBridge application server."
  value       = aws_eip.app.public_ip
}

output "ec2_instance_id" {
  description = "VaultBridge application server instance ID."
  value       = aws_instance.app.id
}

output "ec2_ami_id" {
  description = "Amazon Linux 2023 AMI selected for the instance."
  value       = data.aws_ami.amazon_linux_2023.id
}

output "ec2_key_name" {
  description = "SSH key pair associated with the instance."
  value       = aws_key_pair.vaultbridge.key_name
}
output "rds_endpoint" {
  description = "VaultBridge PostgreSQL connection endpoint."
  value       = aws_db_instance.postgres.endpoint
}

output "rds_address" {
  description = "VaultBridge PostgreSQL DNS address."
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "PostgreSQL database port."
  value       = aws_db_instance.postgres.port
}

output "rds_database_name" {
  description = "Initial PostgreSQL database name."
  value       = aws_db_instance.postgres.db_name
}

output "rds_instance_id" {
  description = "VaultBridge RDS instance identifier."
  value       = aws_db_instance.postgres.id
}