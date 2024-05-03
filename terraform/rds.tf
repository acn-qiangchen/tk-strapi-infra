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
  username               = var.database_username
  password               = var.database_password
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [module.sg.rds_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.rds-subnet-group.name
}

# RDS subnet group
resource "aws_db_subnet_group" "rds-subnet-group" {
  name       = var.database_name
  subnet_ids = [module.network.public_a_id, module.network.public_c_id]
}