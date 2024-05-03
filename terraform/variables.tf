# Global
variable "region" {}
variable "name_prefix" {}
variable "webapp_port" {}

# Tags
variable "tag_name" {}
variable "tag_group" {}

# ECR
#variable "account_id" {}

# SG
variable "sg_ingress_ip_cidr" {}

# Network
variable "az1" {}
variable "az2" {}

# Application Docker Image
variable "app_img_uri" {}

# S3
# variable "envfile_bucket_name" {}
variable "env_file_name" {}


# Database
variable "database_port" {}
variable "database_name" {}
variable "database_username" {}
variable "database_password" {}
variable "database_schema" {}
variable "database_instance_class" {}
variable "database_engine_version" {}
variable "database_engine" {}



locals {
  # Bucket name of env file
  envfile_bucket_name = "${lower(var.name_prefix)}-envfile-${random_integer.s3.result}"
}

resource "random_integer" "s3" {
  min = 10000
  max = 99999
}