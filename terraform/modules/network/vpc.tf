resource "aws_vpc" "default" {
  cidr_block = local.vpc_cidr

  tags = {
    Name  = "${var.tag_name}-vpc"
    group = "${var.tag_group}"
  }
}
