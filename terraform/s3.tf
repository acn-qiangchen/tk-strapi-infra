# Create an S3 bucket for env file
resource "aws_s3_bucket" "envfile_bucket" {
  bucket        = local.envfile_bucket_name
  force_destroy = true

  tags = {
    Name  = "${var.tag_name}-envfile-bucket"
    group = "${var.tag_group}"
  }
}

# Upload the configuration file to the S3 bucket
resource "aws_s3_object" "env_file" {
  bucket = aws_s3_bucket.envfile_bucket.id
  key    = var.env_file_name
  source = local_file.generated_file.filename

  tags = {
    Name  = "${var.tag_name}-envfile"
    group = "${var.tag_group}"
  }
}

# # Upload the configuration file to the S3 bucket
# resource "aws_s3_object" "startup_script" {
#   bucket = aws_s3_bucket.envfile_bucket.id
#   key    = var.db_startup_script_name
#   source = "${path.root}/init-db.sql"

#   tags = {
#     Name  = "${var.tag_name}-init-db"
#     group = "${var.tag_group}"
#   }
# }

# Create a local file using the generated content
resource "local_file" "generated_file" {
  filename = local.envfile_local_name
  content = templatefile("${path.root}/template/tk-strapi-dev.env.tpl", {
    STRAPI_DATABASE_HOST       = aws_db_instance.db.address
    STRAPI_DATABASE_PORT       = "${var.database_port}"
    STRAPI_DATABASE_NAME       = "${var.database_name}"
    STRAPI_DATABASE_USERNAME   = "${var.database_username}"
    STRAPI_DATABASE_PASSWORD   = "${var.database_password}"
    STRAPI_DATABASE_SCHEMA     = "${var.database_schema}"
    STRAPI_S3_ACCESS_KEY_ID    = aws_iam_access_key.strapi_s3_user_access_key.id
    STRAPI_S3_ACCESS_SECRET_ID = aws_iam_access_key.strapi_s3_user_access_key.secret
    STRAPI_S3_BUCKET_NAME      = aws_s3_bucket.strapi_media_bucket.id
    AWS_REGION                 = "${var.region}"
  })
}

#-----strapi s3 plugin-----

# Create the IAM user for strapi s3 provider plugin
resource "aws_iam_user" "strapi_s3_user" {
  name = "${var.name_prefix}-s3_user"
}

# Attach the AmazonS3FullAccess policy to the IAM user
resource "aws_iam_user_policy_attachment" "strapi_s3_user_policy_attachment" {
  user       = aws_iam_user.strapi_s3_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Generate access keys for the IAM user
resource "aws_iam_access_key" "strapi_s3_user_access_key" {
  user = aws_iam_user.strapi_s3_user.name
}

# # Output the access key details
# output "access_key_id" {
#   value = aws_iam_access_key.strapi_s3_user_access_key.id
# }

# output "secret_access_key" {
#   value = aws_iam_access_key.strapi_s3_user_access_key.secret
# }

# Create an S3 bucket for strapi s3 provider
# ref : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl
resource "aws_s3_bucket" "strapi_media_bucket" {
  bucket        = local.mediafile_bucket_name
  force_destroy = true

  tags = {
    Name  = "${var.tag_name}-mediafile-bucket"
    group = "${var.tag_group}"
  }
}

resource "aws_s3_bucket_ownership_controls" "strapi_media_bucket" {
  bucket = aws_s3_bucket.strapi_media_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "strapi_media_bucket" {
  bucket = aws_s3_bucket.strapi_media_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "strapi_media_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.strapi_media_bucket,
    aws_s3_bucket_public_access_block.strapi_media_bucket,
  ]

  bucket = aws_s3_bucket.strapi_media_bucket.id
  acl    = "public-read"
}
