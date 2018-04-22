resource "aws_elb" "elb_app" {
  name            = "${var.app_name}"
  subnets         = ["${aws_subnet.public_az1.id}", "${aws_subnet.public_az2.id}"]
  security_groups = ["${aws_security_group.elb_web.id}"]

  listener {
    instance_port     = "${var.app_port}"
    instance_protocol = "http"
    lb_port           = "${var.app_port}"
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:${var.app_port}/health"
    interval            = 5
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 5
  connection_draining         = true
  connection_draining_timeout = 60
}

data "template_file" "user_data_api" {
  template = "${file("${path.module}/files/app-server.tpl")}"
}

data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name   = "hello-api"
  public_key = "${file("files/hello-api-key.pub")}"
}

data "aws_subnet_ids" "public" {
  vpc_id = "${aws_vpc.vpc_app.id}"

  tags {
    Tier = "Public"
  }

  depends_on = ["aws_route_table.public"]
}

resource "aws_instance" "web" {
  ami                         = "${data.aws_ami.ubuntu_ami.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(data.aws_subnet_ids.public.ids, count.index)}"
  key_name                    = "${aws_key_pair.ssh-key.key_name}"
  user_data                   = "${data.template_file.user_data_api.rendered}"
  associate_public_ip_address = true

  vpc_security_group_ids = ["${aws_security_group.app-web.id}"]

  tags {
    Name = "${var.app_name}-${format("%02d", count.index + 1)}"
  }

  count = "${length(var.availability_zones)}"
}
