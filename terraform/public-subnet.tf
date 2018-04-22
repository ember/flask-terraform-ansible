resource "aws_internet_gateway" "vpc_app" {
  vpc_id = "${aws_vpc.vpc_app.id}"
}

resource "aws_subnet" "public_az1" {
  vpc_id                  = "${aws_vpc.vpc_app.id}"
  cidr_block              = "${var.public_subnet_az1_cidr}"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags {
    Name = "public az1"
    Tier = "Public"
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id                  = "${aws_vpc.vpc_app.id}"
  cidr_block              = "${var.public_subnet_az2_cidr}"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags {
    Name = "public az2"
    Tier = "Public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc_app.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.vpc_app.id}"
  }
}

resource "aws_route_table_association" "public_az1" {
  subnet_id      = "${aws_subnet.public_az1.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public_az2" {
  subnet_id      = "${aws_subnet.public_az2.id}"
  route_table_id = "${aws_route_table.public.id}"
}
