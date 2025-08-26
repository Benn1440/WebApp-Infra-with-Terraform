variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "environment" {
  description = "The environment (dev/prod)"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy to"
  type        = string
  default     = "us-central1"
}

variable "database_version" {
  description = "The database version (e.g., MYSQL_8_0)"
  type        = string
  default     = "MYSQL_8_0"
}

variable "db_name" {
  description = "The name of the database to create"
  type        = string
  default     = "webapp"
}

variable "db_user" {
  description = "The username for the database"
  type        = string
  default     = "webapp-user"
}

# Sensitive variables should be passed via Terraform variables files or environment variables.
variable "db_user_password" {
  description = "The password for the database user"
  type        = string
  sensitive   = true
}

variable "vpc_network" {
  description = "The name of the VPC network to deploy the database in"
  type        = string
}

variable "private_subnet_cidr" {
  description = "The CIDR range of the private subnet for private service access"
  type        = string
}