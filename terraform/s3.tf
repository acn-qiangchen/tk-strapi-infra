# Create an S3 bucket
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
  filename = "tk-strapi-dev.env.generated"
  content = templatefile("${path.root}/template/tk-strapi-dev.env.tpl", {
    STRAPI_DATABASE_HOST       = aws_db_instance.db.address
    STRAPI_DATABASE_PORT       = "${var.database_port}"
    STRAPI_DATABASE_NAME       = "${var.database_name}"
    STRAPI_DATABASE_USERNAME   = "${var.database_username}"
    STRAPI_DATABASE_PASSWORD   = "${var.database_password}"
    STRAPI_DATABASE_SCHEMA     = "${var.database_schema}"
    STRAPI_S3_ACCESS_KEY_ID    = "##TODO"
    STRAPI_S3_ACCESS_SECRET_ID = "##TODO"
    STRAPI_S3_BUCKET_NAME      = aws_s3_bucket.envfile_bucket.id
    AWS_REGION                 = "${var.region}"
  })
}