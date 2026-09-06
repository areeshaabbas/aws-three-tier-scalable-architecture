resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "public-1" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.az_a

  tags = {
    Name = "public-1"
  }
}

resource "aws_subnet" "public-2" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.az_b

  tags = {
    Name = "public-2"
  }
}

resource "aws_subnet" "private-1" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.az_a

  tags = {
    Name = "private-1"
  }
}

resource "aws_subnet" "private-2" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.az_b

  tags = {
    Name = "private-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "route-table-public" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "my-route-table-public"
  }
}

resource "aws_route_table" "route-table-private" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my-ngw.id
  }

  tags = {
    Name = "my-route-table-private"
  }
}

resource "aws_route_table_association" "association-public-1" {
  subnet_id      = aws_subnet.public-1.id
  route_table_id = aws_route_table.route-table-public.id
}

resource "aws_route_table_association" "association-public-2" {
  subnet_id      = aws_subnet.public-2.id
  route_table_id = aws_route_table.route-table-public.id
}

resource "aws_route_table_association" "association_private-1" {
  subnet_id      = aws_subnet.private-1.id
  route_table_id = aws_route_table.route-table-private.id
}

resource "aws_route_table_association" "association-private-2" {
  subnet_id      = aws_subnet.private-2.id
  route_table_id = aws_route_table.route-table-private.id
}

resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "my-ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public-1.id

  tags = {
    Name = "my-ngw"
  }

  depends_on = [aws_internet_gateway.igw]
}