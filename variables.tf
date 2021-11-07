variable "project_id" {
  type = string
  description = "project id"
  default = "data2bots-sandbox"
}

variable "region" {
  type = string
  description = "region"
  default = "us-central1"
}

variable "bucket_name" {
  type = string
  description = "bucket name to be added {project_id}"
  default = "testing+infra"
}
