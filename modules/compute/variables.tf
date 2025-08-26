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

variable "network" {
  description = "The name of the VPC network"
  type        = string
}

variable "subnet" {
  description = "The self link of the subnet for the MIG"
  type        = string
}

variable "db_private_ip" {
  description = "The private IP address of the Cloud SQL database"
  type        = string
  default     = ""
}