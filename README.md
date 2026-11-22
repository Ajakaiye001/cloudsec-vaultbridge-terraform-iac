# VaultBridge — AWS Infrastructure as Code with Terraform

Rebuilding a fictional fintech's manually managed AWS environment in Terraform, after a console change exposed PostgreSQL (5432) to the internet.

- `bootstrap/` creates the S3 bucket for remote state (versioned, encrypted, public access blocked)
- `infra/` holds the main environment (to follow)

Work in progress.
