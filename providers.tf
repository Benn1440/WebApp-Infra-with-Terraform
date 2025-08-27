terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.49.2"
    }
  }
}

# provider "google" {

#    # Configuration options. Credentials are picked up from ADC (gcloud auth application-default login)
#   # You can also explicitly set them here, but it's less secure.
#   # credentials = file("path-to-your-service-account-key.json")
#   project = var.project_id # This variable will be defined in each environment
#   region  = var.region     # This variable will be defined in each environment
# }