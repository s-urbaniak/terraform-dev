resource "aws_instance" "machine" {
  ami                         = data.aws_ami.centos.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet_public.id
  security_groups             = [aws_security_group.sg.id]
  key_name                    = aws_key_pair.key.key_name

  root_block_device {
    volume_size = var.disk_size
  }

  tags = {
    Name = "${var.machine_prefix}-${random_id.machine_suffix.hex}"
  }
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.machine_prefix}-${random_id.machine_suffix.hex}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "subnet_public" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.1.0.0/24"
}

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.rtb_public.id
}

resource "aws_security_group" "sg" {
  name   = "${var.machine_prefix}-${random_id.machine_suffix.hex}"
  vpc_id = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.ports
    iterator = port

    content {
      from_port = port.value
      to_port   = port.value
      protocol  = "tcp"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
    }
  }

  ingress {
    from_port = 51820
    to_port   = 51820
    protocol  = "udp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.machine_prefix}-${random_id.machine_suffix.hex}"
  }
}


resource "aws_key_pair" "key" {
  key_name   = "${var.machine_prefix}-${random_id.machine_suffix.hex}"
  public_key = var.ssh_key
}

data "aws_ami" "centos" {
  most_recent = true
  // See https://wiki.centos.org/Cloud/AWS:
  // AWS Marketplace and are shared directly from official Community Platform Engineering (CPE) account 125523088429.
  owners = ["125523088429"]

  filter {
    name = "name"
    // found via `aws ec2 describe-images --filters 'Name=name,Values=CentOS Stream*' 'Name=architecture,Values=x86_64' --output json`
    values = ["CentOS Stream 9 x86_64 20220705"]
  }
}

resource "random_id" "machine_suffix" {
  byte_length = 2
}
