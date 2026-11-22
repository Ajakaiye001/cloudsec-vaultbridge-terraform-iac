variable "aws_region" {
  description = "AWS region for the VaultBridge infrastructure."
  type        = string
}

variable "my_ip_cidr" {
  description = "Your public IPv4 address in CIDR notation, restricted to /32."
  type        = string

  validation {
    condition     = can(cidrhost(var.my_ip_cidr, 0)) && can(regex("/32$", var.my_ip_cidr))
    error_message = "Provide a valid IPv4 CIDR with a /32 netmask."
  }
}

variable "db_username" {
  description = "Username for the VaultBridge PostgreSQL database."
  type        = string
  sensitive   = true
  default     = null
}

variable "db_password" {
  description = "Password for the VaultBridge PostgreSQL database."
  type        = string
  sensitive   = true
  default     = null
}
variable "public_key_path" {
  description = "Local path to the VaultBridge SSH public key."
  type        = string
}
variable "allowed_account_id" {
  description = "AWS account ID permitted to deploy VaultBridge."
  type        = string
}
