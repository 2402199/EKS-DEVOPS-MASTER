resource "aws_vpc" "EKS-testing" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "EKS-public" {
  vpc_id                  = aws_vpc.EKS-testing.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone1
  map_public_ip_on_launch = true
}

resource "aws_subnet" "EKS-public2" {
  vpc_id                  = aws_vpc.EKS-testing.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = var.availability_zone2 # changed from az1 -> az2
  map_public_ip_on_launch = true
}

resource "aws_subnet" "EKS-private" {
  vpc_id            = aws_vpc.EKS-testing.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zone2
}

resource "aws_subnet" "EKS-private2" {
  vpc_id            = aws_vpc.EKS-testing.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.availability_zone3
}

resource "aws_internet_gateway" "EKS-igw" {
  vpc_id = aws_vpc.EKS-testing.id
}

resource "aws_route_table" "EKS-pubRT" {
  vpc_id = aws_vpc.EKS-testing.id
}

resource "aws_route_table" "EKS-pubRT2" {
  vpc_id = aws_vpc.EKS-testing.id
}

resource "aws_route_table" "EKS-priRT" {
  vpc_id = aws_vpc.EKS-testing.id
}

resource "aws_route_table" "EKS-priRT2" {
  vpc_id = aws_vpc.EKS-testing.id
}

resource "aws_route_table_association" "EKS-PUB" {
  route_table_id = aws_route_table.EKS-pubRT.id
  subnet_id      = aws_subnet.EKS-public.id
}

resource "aws_route_table_association" "EKS-PUB2" {
  route_table_id = aws_route_table.EKS-pubRT2.id # fixed to pubRT2
  subnet_id      = aws_subnet.EKS-public2.id
}

resource "aws_route_table_association" "EKS-pri" {
  route_table_id = aws_route_table.EKS-priRT.id
  subnet_id      = aws_subnet.EKS-private.id
}

resource "aws_route_table_association" "EKS-pri2" {
  route_table_id = aws_route_table.EKS-priRT2.id
  subnet_id      = aws_subnet.EKS-private2.id
}

resource "aws_nat_gateway" "EKS-nat" {
  subnet_id     = aws_subnet.EKS-public.id
  depends_on    = [aws_internet_gateway.EKS-igw]
  allocation_id = aws_eip.elastic.id
}

resource "aws_nat_gateway" "EKS-nat2" {
  subnet_id     = aws_subnet.EKS-public2.id # fixed to public2 subnet
  depends_on    = [aws_internet_gateway.EKS-igw]
  allocation_id = aws_eip.elastic2.id
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.EKS-pubRT.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.EKS-igw.id
}

resource "aws_route" "internet2" {
  route_table_id         = aws_route_table.EKS-pubRT2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.EKS-igw.id
}

resource "aws_route" "nat" {
  route_table_id         = aws_route_table.EKS-priRT.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.EKS-nat.id
}

resource "aws_route" "nat2" {
  route_table_id         = aws_route_table.EKS-priRT2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.EKS-nat2.id
}

resource "aws_security_group" "pubSG" {
  vpc_id = aws_vpc.EKS-testing.id
  tags = {
    "Name" = "pubSG"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 0
    to_port     = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "priSG" {
  vpc_id = aws_vpc.EKS-testing.id
  tags = {
    "Name" = "priSG"
  }

  ingress {
    protocol        = "tcp"
    from_port       = 0
    to_port         = 65535
    security_groups = [aws_security_group.pubSG.id]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "elastic" {
  domain = "vpc"
}

resource "aws_eip" "elastic2" {
  domain = "vpc"
}
