# Terraform のバージョン指定
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

# プロバイダーを指定
provider "aws" {
  region = var.region
}

# ECR
# module "ecr" {
#   source = "./modules/ecr"

#   name_prefix = var.name_prefix
#   region = var.region
#   tag_name = var.tag_name
#   tag_group = var.tag_group

#   account_id = var.account_id
# }

# IAM
module "iam" {
  source = "./modules/iam"

  name_prefix = var.name_prefix
  region      = var.region
  tag_name    = var.tag_name
  tag_group   = var.tag_group
}

# # Network
module "network" {
  source      = "./modules/network"
  name_prefix = var.name_prefix
  region      = var.region
  tag_name    = var.tag_name
  tag_group   = var.tag_group
  az1         = var.az1
  az2         = var.az2
}

# # Security Group
module "sg" {
  source = "./modules/sg"

  name_prefix = var.name_prefix
  region      = var.region
  tag_name    = var.tag_name
  tag_group   = var.tag_group

  vpc_id             = module.network.vpc_id
  sg_ingress_ip_cidr = var.sg_ingress_ip_cidr
}

# # Cloud Watch
module "cloudwatch" {
  source = "./modules/cloudwatch"

  name_prefix = var.name_prefix
  region      = var.region
  tag_name    = var.tag_name
  tag_group   = var.tag_group
}

# # ALB
module "alb" {
  source = "./modules/alb"

  name_prefix = var.name_prefix
  region      = var.region
  tag_name    = var.tag_name
  tag_group   = var.tag_group

  vpc_id      = module.network.vpc_id
  public_a_id = module.network.public_a_id
  public_c_id = module.network.public_c_id
  sg_id       = module.sg.sg_id
}

# # ECS
module "ecs" {
  source = "./modules/ecs"

  name_prefix = var.name_prefix
  region      = var.region
  webapp_port = var.webapp_port
  tag_name    = var.tag_name
  tag_group   = var.tag_group

  # Service
  logs_group_name = module.cloudwatch.logs_group_name
  tg_arn          = module.alb.tg_arn
  public_a_id     = module.network.public_a_id
  public_c_id     = module.network.public_c_id
  sg_id           = module.sg.sg_id
  # Task
  #ecr_repository_uri = "${module.ecr.repository_uri}"
  ecr_repository_uri = var.app_img_uri
  execution_role_arn = module.iam.execution_role_arn

  #S3
  env_file_bucket = local.envfile_bucket_name
  env_file_name   = var.env_file_name

  # application startup fails if envfile or db is not ready
  depends_on = [aws_s3_object.env_file, aws_db_instance.db]
}
