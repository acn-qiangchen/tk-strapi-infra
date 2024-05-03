# Global
variable "region" {}
variable "name_prefix" {}

# Tags
variable "tag_name" {}
variable "tag_group" {}

# Internet Gateway

# Subnet
variable "az1" {}
variable "az2" {}

locals {
  vpc_cidr = "10.0.0.0/16"
}
