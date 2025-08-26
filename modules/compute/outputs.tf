output "load_balancer_ip" {
  description = "The public IP address of the HTTP(S) Load Balancer"
  value       = google_compute_global_forwarding_rule.web_forwarding_rule.ip_address
}

output "mig_name" {
  description = "The name of the Managed Instance Group"
  value       = google_compute_instance_group_manager.web_mig.name
}