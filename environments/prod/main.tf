terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.49.2"
    }
  }
}

provider "google" {

   # Configuration options. Credentials are picked up from ADC (gcloud auth application-default login)
  # You can also explicitly set them here, but it's less secure.
  # credentials = file("path-to-your-service-account-key.json")
  project = var.project_id # This variable will be defined in each environment
  region  = var.region     # This variable will be defined in each environment
}

# Get the common variables (same as dev)
variable "project_id" {
  type = string
}
variable "region" {
  type = string
}
variable "environment" {
  type = string
}
variable "vpc_cidr" {
  type = string
}
variable "db_name" {
  type = string
}
variable "db_user" {
  type = string
}
variable "db_user_password" {
  type      = string
  sensitive = true
}

module "networking" {
  source      = "../../modules/networking"
  project_id  = var.project_id
  region      = var.region
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

module "database" {
  source              = "../../modules/database"
  project_id          = var.project_id
  region              = var.region
  environment         = var.environment
  vpc_network         = module.networking.vpc_self_link
  db_name             = var.db_name
  db_user             = var.db_user
  db_user_password    = var.db_user_password
  # private_subnet_cidr = module.networking.private_subnet_ids[0].ip_cidr_range
  private_subnet_cidr = module.networking.private_subnet_cidr_blocks[0]
  database_version    = "MYSQL_8_0"
  # Use a production-grade database tier
  # You would override the 'tier' setting by adding a variable in the database module for this.
}

module "compute" {
  source        = "../../modules/compute"
  project_id    = var.project_id
  region        = var.region
  environment   = var.environment
  network       = module.networking.network_name
  subnet        = module.networking.private_subnet_ids[0]
  db_private_ip = module.database.db_private_ip
  # You could override the machine_type or min/max replicas here for prod
  # by adding those as variables in the compute module.
}
