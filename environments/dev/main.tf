# Get the common variables
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

# Create the Networking foundation
module "networking" {
  source      = "../../modules/networking"
  project_id  = var.project_id
  region      = var.region
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

# Create the Database
module "database" {
  source              = "../../modules/database"
  project_id          = var.project_id
  region              = var.region
  environment         = var.environment
  vpc_network         = module.networking.network_name
  db_name             = var.db_name
  db_user             = var.db_user
  db_user_password    = var.db_user_password
  # Use the CIDR of the first private subnet for Private Service Access alignment
  private_subnet_cidr = module.networking.private_subnet_ids[0].ip_cidr_range
}

# Create the Compute Layer (Web Servers and Load Balancer)
module "compute" {
  source        = "../../modules/compute"
  project_id    = var.project_id
  region        = var.region
  environment   = var.environment
  network       = module.networking.network_name
  # For a real multi-zone setup, you might create a MIG per zone.
  # This points the MIG to the first private subnet in us-central1-a.
  subnet        = module.networking.private_subnet_ids[0].id
  db_private_ip = module.database.db_private_ip
}
