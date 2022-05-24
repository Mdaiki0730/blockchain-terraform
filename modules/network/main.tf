// vpc
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix}-vpc"
  }
}

// internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.prefix}-igw"
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

// eip
resource "aws_eip" "nat_2a" {
  vpc = true

  tags = {
    Name = "${var.prefix}-natgw-2a"
  }
}

resource "aws_eip" "nat_2c" {
  vpc = true

  tags = {
    Name = "${var.prefix}-natgw-2c"
  }
}

// nat gateway
resource "aws_nat_gateway" "nat_2a" {
  allocation_id = aws_eip.nat_2a.id
  subnet_id     = aws_subnet.public_2a.id

  tags = {
    Name = "${var.prefix}-nat-2a"
  }
}

resource "aws_nat_gateway" "nat_2c" {
  allocation_id = aws_eip.nat_2c.id
  subnet_id     = aws_subnet.public_2c.id

  tags = {
    Name = "${var.prefix}-nat-2c"
  }
}

// public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.prefix}-public-route-table"
  }
}

resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_2a" {
  subnet_id      = aws_subnet.public_2a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2c" {
  subnet_id      = aws_subnet.public_2c.id
  route_table_id = aws_route_table.public.id
}

// private route table
resource "aws_route_table" "private_2a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2a.id
  }

  tags = {
    Name = "${var.prefix}--private-2a"
  }
}

resource "aws_route_table" "private_2c" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2c.id
  }

  tags = {
    Name = "${var.prefix}--private-2c"
  }
}

resource "aws_route_table_association" "private_2a" {
  subnet_id      = aws_subnet.private_2a.id
  route_table_id = aws_route_table.private_2a.id
}

resource "aws_route_table_association" "private_2c" {
  subnet_id      = aws_subnet.private_2c.id
  route_table_id = aws_route_table.private_2c.id
}
