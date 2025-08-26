# Create a Service Account for the Compute Instances
resource "google_service_account" "instance_sa" {
  account_id   = "${var.environment}-instance-sa"
  display_name = "Service Account for ${var.environment} Compute Instances"
  project      = var.project_id
}

# Create an Instance Template
resource "google_compute_instance_template" "web_template" {
  name_prefix  = "${var.environment}-web-template-"
  description  = "Instance template for ${var.environment} web servers"
  project      = var.project_id
  region       = var.region
  machine_type = "e2-small" # Choose an appropriate machine type

  # Specify the disk and image (Using a simple Debian image for example)
  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  # Network interface in the specified subnet
  network_interface {
    network    = var.network
    subnetwork = var.subnet
    # No external IP - instances are private
  }

  # Apply the firewall rule tag and service account
  tags = ["http-server"]

  service_account {
    email  = google_service_account.instance_sa.email
    scopes = ["cloud-platform"] # Broad scope for example; restrict for production
  }

  # User data script to install and start a web server (e.g., Apache, Nginx)
  # This is a simple example. You would replace this with your application setup.
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
    # Example: Set a homepage that shows the hostname
    echo "<html><body><h1>Hello from ${var.environment}! Host: $(hostname)</h1></body></html>" > /var/www/html/index.html
  EOF

  # Lifecycle rule to ignore changes to the specific instance image
  lifecycle {
    create_before_destroy = true
  }
}

# Create a Health Check for the Load Balancer and MIG
resource "google_compute_health_check" "http_health_check" {
  name               = "${var.environment}-http-health-check"
  project            = var.project_id
  check_interval_sec = 5
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 3 # 3 consecutive failures to mark unhealthy

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

# Create the Managed Instance Group (MIG)
resource "google_compute_instance_group_manager" "web_mig" {
  name               = "${var.environment}-web-mig"
  project            = var.project_id
  base_instance_name = "${var.environment}-web"
  zone               = "${var.region}-a" # For multi-zone, you would create multiple MIGs or use a regional MIG.
  target_size        = 2 # Initial size

  version {
    instance_template = google_compute_instance_template.web_template.id
  }

  # Connect the health check to the MIG for auto-healing
  auto_healing_policies {
    health_check      = google_compute_health_check.http_health_check.id
    initial_delay_sec = 300 # Wait 5 minutes before starting health checks
  }
}

# Create an Autoscaler for the MIG
resource "google_compute_autoscaler" "web_autoscaler" {
  name   = "${var.environment}-web-autoscaler"
  project = var.project_id
  zone   = "${var.region}-a"
  target = google_compute_instance_group_manager.web_mig.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.8 # Scale out if CPU utilization is above 80%
    }
  }
}

# ========== LOAD BALANCER CONFIGURATION ==========
# This is a more complex setup. The following creates a global HTTP(S) Load Balancer.

# Backend Service for the MIG
resource "google_compute_backend_service" "web_backend" {
  name                  = "${var.environment}-web-backend"
  project               = var.project_id
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  enable_cdn            = false

  backend {
    group           = google_compute_instance_group_manager.web_mig.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }

  health_checks = [google_compute_health_check.http_health_check.id]
}

# URL Map to route all traffic to the backend service
resource "google_compute_url_map" "web_url_map" {
  name            = "${var.environment}-web-url-map"
  project         = var.project_id
  default_service = google_compute_backend_service.web_backend.id
}

# HTTP Target Proxy
resource "google_compute_target_http_proxy" "web_http_proxy" {
  name    = "${var.environment}-web-http-proxy"
  project = var.project_id
  url_map = google_compute_url_map.web_url_map.id
}

# Global Forwarding Rule (This is the public IP that receives traffic)
resource "google_compute_global_forwarding_rule" "web_forwarding_rule" {
  name                  = "${var.environment}-web-forwarding-rule"
  project               = var.project_id
  target                = google_compute_target_http_proxy.web_http_proxy.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL"
  ip_protocol           = "TCP"
}