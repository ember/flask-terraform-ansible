resource "aws_subnet" "private_az1" {
  vpc_id                  = "${aws_vpc.vpc_app.id}"
  cidr_block              = "${var.private_subnet_az1_cidr}"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags {
    Name = "private az1"
  }
}

resource "aws_subnet" "private_az2" {
  vpc_id                  = "${aws_vpc.vpc_app.id}"
  cidr_block              = "${var.private_subnet_az2_cidr}"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false

  tags {
    Name = "private az2"
  }
}
