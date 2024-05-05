resource "aws_subnet" "public_a" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.default.id
  availability_zone = var.az1
  map_public_ip_on_launch = true

  tags = {
    Name  = "${var.tag_name}-subnet1"
    group = "${var.tag_group}"
  }
}

resource "aws_subnet" "public_c" {
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.default.id
  availability_zone = var.az2
  map_public_ip_on_launch = true

  tags = {
    Name  = "${var.tag_name}-subnet2"
    group = "${var.tag_group}"
  }
}
