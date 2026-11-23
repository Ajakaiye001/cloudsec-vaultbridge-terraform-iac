# Find the latest Amazon Linux 2023 x86_64 AMI.
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Register the VaultBridge SSH public key with AWS.
resource "aws_key_pair" "vaultbridge" {
  key_name   = "vaultbridge-lab-key"
  public_key = file(var.public_key_path)

  tags = {
    Name = "vaultbridge-lab-key"
  }
}

# VaultBridge application server.
resource "aws_instance" "app" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"

  # Place the server in the first public subnet.
  subnet_id = aws_subnet.public[0].id

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  key_name = aws_key_pair.vaultbridge.key_name

  # Elastic IP will provide the server's public address.
  associate_public_ip_address = true

  # Install the PostgreSQL client during first boot.
  user_data = <<-EOF
    #!/bin/bash
    set -eux

    yum update -y
    yum install -y postgresql15
  EOF

  # Encrypted GP3 root volume.
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name = "vaultbridge-ec2-root"
    }
  }

  # Require Instance Metadata Service Version 2.
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "vaultbridge-app-server"
    Role = "Application"
  }
}

# Allocate a static Elastic IP.
resource "aws_eip" "app" {
  domain = "vpc"

  tags = {
    Name = "vaultbridge-app-eip"
  }
}

# Associate the Elastic IP with EC2.
resource "aws_eip_association" "app" {
  allocation_id = aws_eip.app.id
  instance_id   = aws_instance.app.id
}
