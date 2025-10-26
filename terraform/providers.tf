terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.29"        # keep in sync with env
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.29"
    }
  }

  # --- Optional: remote state backend (uncomment after you bootstrap the bucket) ---
  # backend "gcs" {
  #   bucket = "sr-eng-prep-tf-state"   # create this bucket once, outside TF or via a bootstrap step
  #   prefix = "gke-autoscaling-lab"    # folder-like prefix for state objects
  # }
}

# Core Google provider (uses ADC; no key file needed)
provider "google" {
  project = var.project_id
  region  = var.region
}

# Expose beta resources/features when needed (safe to keep alongside stable)
provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# --- Optional: if you later want to drive Kubernetes resources via TF ---
# We’ll stick to kubectl today, but here’s the skeleton you’d use:
#
# data "google_container_cluster" "primary" {
#   name     = var.cluster_name
#   location = var.region
# }
#
# provider "kubernetes" {
#   host                   = "https://${data.google_container_cluster.primary.endpoint}"
#   cluster_ca_certificate = base64decode(data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
#   token                  = data.google_client_config.default.access_token
# }
#
# data "google_client_config" "default" {}