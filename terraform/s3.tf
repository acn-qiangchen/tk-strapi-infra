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
resource "aws_s3_bucket" "strapi_media_bucket" {
  bucket        = local.mediafile_bucket_name
  force_destroy = true

  tags = {
    Name  = "${var.tag_name}-mediafile-bucket"
    group = "${var.tag_group}"
  }
}