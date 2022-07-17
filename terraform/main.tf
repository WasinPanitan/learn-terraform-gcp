# main
terraform {
  backend "local" {}
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.25.0"
    }
  }
}

provider "google" {
  credentials = file("../gcp-credential.json")

  project = var.project_id
  region = var.region
  zone = var.zone
}