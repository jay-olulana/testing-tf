locals {
  bucket_name = format("%s-%s", var.project_id, var.bucket_name)
}

##########################################
##  Define resources
##########################################

# create resource template for the gcs data lake
resource "google_storage_bucket" "data_lake" {
  name = local.bucket_name
  project = var.project_id
  location = var.region

  storage_class = "MULTI_REGIONAL" # other options are MULTI_REGIONAL, STANDARD, NEARLINE, COLDLINE, REGIONAL, ARCHIVE

  force_destroy = true # defines if the bucket object should be deleted when the resource is destroyed

  uniform_bucket_level_access = true # defines the bucket level access policy

  #NOT WORKING FOR NOW  Error reading bucket after creation: googleapi: 
  #                     Error 400: Bucket is requester pays bucket but no 
  #                     user project provided., required (you change it to false)

  # requester_pays = true # defines if the requester pays for the storage when pulling objects from the bucket
  
  # retention policy for how long objects in the bucket should be retained.
  ##NOTE:## Versioning and retention policy can't be used together
  # retention_policy {
  #   is_locked = false
  #   retention_period = 90 # defines the retention period in seconds
  # }
  
#   encryption {
#     # defines the encryption settings for the bucket
#     default_kms_key_name = "NONE"
#   }

  # define logging storage location for the bucket
  logging {
    log_bucket = local.bucket_name
    log_object_prefix = "logs"
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
  
  # define the website configuration if the bucket is to be used as a website??
  # cors {
  #   max_age_seconds = 3600
  #   allowed_methods = ["GET", "POST", "PUT", "DELETE", "HEAD", "OPTIONS"]
  #   allowed_origins = ["*"]
  #   allowed_headers = ["*"]
  # }
  
  # defines if we want versioning or not
  versioning {
    enabled = true
  }

  labels = {
    "data-lake" = "true"
  }
}

# # create permissions resource template for the bucket 
####
# COMMENTED OUT BECAUSE WE ALREADY DEFINE A POLICY DATA IN THE RESOURCE BELOW
####
# resource "google_storage_bucket_iam_binding" "data_lake_permissions" {
#   bucket = google_storage_bucket.data_lake.name
#   role = "roles/storage.objectViewer"
#   members = [
#     "allAuthenticatedUsers",
#   ]
# }

# create the data lake bucket policy
resource "google_storage_bucket_iam_policy" "data_lake_policy" {
  bucket = google_storage_bucket.data_lake.name
  policy_data = <<POLICY
{
  "bindings": [
    {
      "members": [
        "group:data2bots-tech-team@data2bots.com"
      ],
      "role": "roles/storage.admin"
    }
  ]
}
POLICY
}

# resource "google_storage_bucket_iam_binding" "bucket_iam" {
#   bucket = google_storage_bucket.data_lake.name
#   role = "roles/storage.buckets.getIamPolicy"
#   members = [
#     "allAuthenticatedUsers"
#   ]
# }
