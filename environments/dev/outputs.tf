output "load_balancer_ip" {
  description = "The public IP address to access the web application"
  value       = module.compute.load_balancer_ip
}

output "db_private_ip" {
  description = "The private IP address of the database for debugging"
  value       = module.database.db_private_ip
  sensitive   = true
}

output "db_connection_name" {
  description = "The connection name for the database instance"
  value       = module.database.db_connection_name
}
