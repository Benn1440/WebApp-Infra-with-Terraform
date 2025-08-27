output "vpc_id" {
  value = google_compute_network.vpc.id
}

output "public_subnet_ids" {
  description = "The list of IDs of the public subnets."
  value       = google_compute_subnetwork.public_subnet[*].id
}

output "private_subnet_ids" {
  description = "The list of IDs of the private subnets."
  value       = google_compute_subnetwork.private_subnet[*].id
}

output "network_name" {
  value = google_compute_network.vpc.name
}

output "private_subnet_cidr_blocks" {
  description = "The list of CIDR blocks for the private subnets."
  value       = google_compute_subnetwork.private_subnet[*].ip_cidr_range
}

output "vpc_self_link" {
  description = "The self-link of the VPC network."
  value       = google_compute_network.vpc.self_link
}



# output "vpc_id" {
#   value = google_compute_network.vpc.id
# }

# output "public_subnet_ids" {
#   value = google_compute_subnetwork.public_subnet.id
# }

# output "private_subnet_ids" {
#   value = google_compute_subnetwork.private_subnet.id
# }

# output "network_name" {
#   value = google_compute_network.vpc.name
# }

# output "private_subnet_cidr_blocks" {
#   description = "The CIDR blocks for the private subnets."
#   value       = google_compute_subnetwork.private_subnet.ip_cidr_range
# }

# output "private_subnet_ids" {
#   description = "The IDs of the private subnets."
#   value       = [
#     google_compute_subnetwork.private_subnets["subnet-1"].id,
#     google_compute_subnetwork.private_subnets["subnet-2"].id
#   ]
# }

# output "vpc_self_link" {
#   description = "The self-link of the VPC network."
#   value       = google_compute_network.vpc.self_link
# }