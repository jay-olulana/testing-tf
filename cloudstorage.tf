########################################################################
##  Define provider, variables.
##  I am defining them here because we don't way to define them globally.
########################################################################



locals {
  bucket_name = format("%s-%s", var.project_id, var.region)
}

##########################################
##  Define resources
##########################################

# create resource template for the gcs data lake
resource "google_storage_bucket" "data_lake" {
  name = local.bucket_name

  location = var.region

  storage_class = "REGIONAL" # other options are MULTI_REGIONAL, STANDARD, NEARLINE, COLDLINE

  force_destroy = true # defines if the bucket object should be deleted when the resource is destroyed

  uniform_bucket_level_access = true # defines the bucket level access policy

  requester_pays = true # defines if the requester pays for the storage when pulling objects from the bucket

  retention_policy {
    retention_period = 90 # defines the retention period in days
  }
  encryption {
    # defines the encryption settings for the bucket
    default_kms_key_name = "NONE"
  }

  # define logging storage location for the bucket
  logging {
    log_bucket = local.bucket_name
    log_object_prefix = "logs"
  }
  lifecycle {
    ignore_changes = [
      "force_destroy",
      "requester_pays",
      "uniform_bucket_level_access"
    ]
  }
  # define the data lifecycle management policy
  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 365
    }
  }
  versioning {
    enabled = true
  }

  labels = {
    "data-lake" = "true"
  }
}

# create permissions resource template for the bucket
resource "google_storage_bucket_iam_binding" "data_lake_permissions" {
  bucket = google_storage_bucket.data_lake.name
  role = "roles/storage.objectViewer"
  members = [
    "allAuthenticatedUsers",
  ]
}

# create the data lake bucket policy
resource "google_storage_bucket_iam_policy" "data_lake_policy" {
  bucket = google_storage_bucket.data_lake.name
  policy_data = <<POLICY
{
  "bindings": [
    {
      "members": [
        "allAuthenticatedUsers"
      ],
      "role": "roles/storage.objectViewer"
    }
  ]
}
POLICY
}
