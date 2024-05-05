# Retrieve the latest Amazon Linux AMI ID
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    #values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    values = ["al2023-ami-2023.4.20240429.0-kernel-6.1-x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# INSTANCES #
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = module.network.public_a_id
  vpc_security_group_ids = [module.sg.bastion_id]
  #iam_instance_profile   = module.web_app_s3.instance_profile.name
  depends_on = [aws_db_instance.db]

  user_data = templatefile("${path.module}/template/create-schema.tpl", {
    DB_HOST     = aws_db_instance.db.address
    DB_PORT     = aws_db_instance.db.port
    DB_USERNAME = aws_db_instance.db.username
    DB_PASSWORD = aws_db_instance.db.password
    DB_NAME     = aws_db_instance.db.db_name
    DB_SCHEMA   = "${var.database_schema}"
  })
  user_data_replace_on_change = true

  tags = {
    Name  = "${var.tag_name}-bastion"
    group = "${var.tag_group}"
  }
}