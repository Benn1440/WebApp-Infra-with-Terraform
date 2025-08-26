# Reserve a global internal IP range for Private Service Access
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.environment}-private-ip-range"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.vpc_network
}

# Enable Private Service Access connection
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.vpc_network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  depends_on              = [google_compute_global_address.private_ip_address]
}

# Create the Cloud SQL MySQL Instance
resource "google_sql_database_instance" "main" {
  name             = "${var.environment}-mysql-instance"
  project          = var.project_id
  region           = var.region
  database_version = var.database_version

  # Settings for the instance. Use a higher tier for production.
  settings {
    tier = "db-f1-micro" # Dev/Test tier. Use db-n1-standard-1 for prod.

    ip_configuration {
      ipv4_enabled    = false # No public IP - make it private
      private_network = var.vpc_network
    }

    backup_configuration {
      enabled = true
    }

    maintenance_window {
      day  = 7 # Sunday
      hour = 3 # 3 AM
    }
  }

  # This is crucial: the database creation must wait for the private network to be ready.
  depends_on = [google_service_networking_connection.private_vpc_connection]

  deletion_protection = false # Set to 'true' for production environments!
}

# Create the actual database inside the instance
resource "google_sql_database" "webapp" {
  name     = var.db_name
  project  = var.project_id
  instance = google_sql_database_instance.main.name
}

# Create a user for the application
resource "google_sql_user" "webapp_user" {
  name     = var.db_user
  project  = var.project_id
  instance = google_sql_database_instance.main.name
  password = var.db_user_password # In a real project, use a secret manager for this.
}