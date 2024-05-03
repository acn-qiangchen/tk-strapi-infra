# Global
variable "region" {}
variable "name_prefix" {}
variable "webapp_port" {}

# Tags
variable "tag_name" {}
variable "tag_group" {}

# ECR
variable "account_id" {}

# SG
variable "sg_ingress_ip_cidr" {}

# Network
variable "az1" {}
variable "az2" {}

# Application Docker Image
variable app_img_uri {}