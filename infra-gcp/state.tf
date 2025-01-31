terraform {
  backend "gcs" {
    bucket  = "bhasaideploymentstorage"
    prefix  = "terraform/bhasai/live/dev-k8s"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.0.0"
    }
  }
}

resource "google_compute_project_metadata" "default" {
  project       = var.resource_group_name
  metadata = {
    delete_os_disk_on_deletion = "true" # Placeholder, manage VM deletion logic in your configurations
  }
}
