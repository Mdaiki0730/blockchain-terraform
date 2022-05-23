// vpc
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

// subnet
resource "aws_subnet" "public_2a" {
  vpc_id = aws_vpc.main.id

  availability_zone = "us-west-2a"

  cidr_block = var.public_2a_cidr_block

  tags = {
    Name = "${var.prefix}-public-2a"
  }
}

resource "aws_subnet" "public_2c" {
  vpc_id = aws_vpc.main.id

  availability_zone = "us-west-2c"

  cidr_block = var.public_2c_cidr_block

  tags = {
    Name = "${var.prefix}-public-2c"
  }
}

resource "aws_subnet" "private_2a" {
  vpc_id = aws_vpc.main.id

  availability_zone = "us-west-2a"

  cidr_block = var.private_2a_cidr_block

  tags = {
    Name = "${var.prefix}-private-2a"
  }
}

resource "aws_subnet" "private_2c" {
  vpc_id = aws_vpc.main.id

  availability_zone = "us-west-2c"

  cidr_block = var.private_2c_cidr_block

  tags = {
    Name = "${var.prefix}-private-2c"
  }
}
