
# ==========================================
# RDS DB SUBNET GROUP
# ==========================================

# Place the database in both private subnets.
resource "aws_db_subnet_group" "main" {
  name        = "vaultbridge-private-db-subnets"
  description = "Private subnets for VaultBridge PostgreSQL"

  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "vaultbridge-private-db-subnets"
    Tier = "Private"
  }
}


# ==========================================
# POSTGRESQL PARAMETER GROUP
# ==========================================

resource "aws_db_parameter_group" "postgres" {
  name        = "vaultbridge-postgres15-params"
  family      = "postgres15"
  description = "VaultBridge PostgreSQL 15 logging configuration"

  # Log successful database connections.
  parameter {
    name         = "log_connections"
    value        = "1"
    apply_method = "immediate"
  }

  tags = {
    Name = "vaultbridge-postgres15-params"
  }
}


# ==========================================
# POSTGRESQL DATABASE INSTANCE
# ==========================================

resource "aws_db_instance" "postgres" {
  identifier = "vaultbridge-postgres-dev"

  engine         = "postgres"
  engine_version = "15.19"
  instance_class = "db.t3.micro"

  # Initial database.
  db_name  = "appdb"
  username = var.db_username
  password = var.db_password
  port     = 5432


  # Storage configuration.
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  # Network isolation.
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  # Custom PostgreSQL configuration.
  parameter_group_name = aws_db_parameter_group.postgres.name

  # Training environment only.
  skip_final_snapshot = true

  # Preserve project tags on automated snapshots.
  copy_tags_to_snapshot = true

  tags = {
    Name = "vaultbridge-postgres"
    Role = "Database"
  }
}
