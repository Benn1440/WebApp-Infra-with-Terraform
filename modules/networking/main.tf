# Create the VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.environment}-vpc"
  auto_create_subnetworks = false
  project                 = var.project_id
}

# Create Public Subnets
resource "google_compute_subnetwork" "public_subnet" {
  count         = 2
  name          = "${var.environment}-public-subnet-${count.index}"
  ip_cidr_range = cidrsubnet(var.vpc_cidr, 8, count.index) # e.g., 10.0.0.0/24, 10.0.1.0/24
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id
}

# Create Private Subnets (for GCE and Cloud SQL)
resource "google_compute_subnetwork" "private_subnet" {
  count         = 2
  name          = "${var.environment}-private-subnet-${count.index}"
  ip_cidr_range = cidrsubnet(var.vpc_cidr, 8, count.index + 10) # e.g., 10.0.10.0/24, 10.0.11.0/24
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id
  private_ip_google_access = true # Allows VMs to access Google APIs (e.g., Cloud Storage)
}

# Create a Cloud Router for NAT
resource "google_compute_router" "router" {
  name    = "${var.environment}-router"
  region  = var.region
  network = google_compute_network.vpc.id
  project = var.project_id
}

# Create a Cloud NAT Gateway for private subnets
resource "google_compute_router_nat" "nat" {
  name                               = "${var.environment}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private_subnet[0].id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
  subnetwork {
    name                    = google_compute_subnetwork.private_subnet[1].id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

# Firewall Rule: Allow HTTP, HTTPS, and SSH from anywhere (for LB and debugging)
resource "google_compute_firewall" "allow_web" {
  name    = "${var.environment}-allow-web"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"] # This tag will be assigned to our VMs
}

# Firewall Rule: Allow internal traffic
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.environment}-allow-internal"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = [var.vpc_cidr]
}

# Firewall Rule: Allow health checks from Google Cloud LB
resource "google_compute_firewall" "allow_lb_health_check" {
  name    = "${var.environment}-allow-lb-health-check"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"] # GCP LB health check IP ranges
  target_tags   = ["http-server"]
}