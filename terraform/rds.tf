#--------------------------------------------------------------
# RDS
#--------------------------------------------------------------
resource "aws_db_instance" "db" {
  allocated_storage      = 20
  storage_type           = "gp3"
  engine                 = var.database_engine
  engine_version         = var.database_engine_version
  instance_class         = var.database_instance_class
  identifier             = var.database_name
  db_name                = var.database_name
  username               = var.database_username
  password               = var.database_password
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [module.sg.rds_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.rds-subnet-group.name
  # # Run psql command on the RDS instance
  # provisioner "local-exec" {
  #   command = <<EOT
  #     #!/bin/bash
  #     PGPASSWORD="${aws_db_instance.db.password}" psql \
  #       --host="${aws_db_instance.db.address}" \
  #       --port="${aws_db_instance.db.port}" \
  #       --username="${aws_db_instance.db.username}" \
  #       --dbname="${aws_db_instance.db.name}" \
  #       --file="${path.root}/scripts/create-schema.sql"
  #   EOT
  # }
}

# RDS subnet group
resource "aws_db_subnet_group" "rds-subnet-group" {
  name       = var.database_name
  subnet_ids = [module.network.public_a_id, module.network.public_c_id]
}

#----------
# Create an option group with a database initialization script
# resource "aws_db_option_group" "db_option_group" {
#   name                     = "my-option-group"
#   engine_name              = var.database_engine
#   major_engine_version     = var.database_engine_version
#   option_group_description = "Option group for PostgreSQL with custom initialization script"
# }

# # Attach the database initialization script to the option group
# resource "aws_db_option_group_option" "init_script_option" {
#   option_group_name = aws_db_option_group.db_option_group.name
#   option_name       = "postgis"
#   port              = 5432
#   #version           = "13.4"
#   version = var.database_engine_version
#   option_settings = [
#     {
#       name  = "postgis.enable_extension"
#       value = "true"
#     },
#     {
#       name  = "postgis.extensions"
#       value = "postgis"
#     },
#     {
#       name  = "postgis.global_scripts"
#       value = aws_s3_object.startup_script.key
#       #value = "s3://my-bucket/init_script.sql"  # Path to your custom initialization script
#     }
#   ]
# }

