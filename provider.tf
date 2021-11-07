provider "google" {
  credentials = file("${path.root}/credentials.json")
  project = var.project_id
  region = var.region
}

