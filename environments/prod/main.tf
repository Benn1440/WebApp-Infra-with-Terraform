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
  vpc_network         = module.networking.network_name
  db_name             = var.db_name
  db_user             = var.db_user
  db_user_password    = var.db_user_password
  private_subnet_cidr = module.networking.private_subnet_ids[0].ip_cidr_range
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
  subnet        = module.networking.private_subnet_ids[0].id
  db_private_ip = module.database.db_private_ip
  # You could override the machine_type or min/max replicas here for prod
  # by adding those as variables in the compute module.
}
