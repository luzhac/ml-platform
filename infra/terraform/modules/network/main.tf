resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

}

# public

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.region}c"
  map_public_ip_on_launch = true

  tags = {

    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {

    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

}

resource "aws_route_table_association" "assoc_pub_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id

}

resource "aws_route_table_association" "assoc_pub_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public.id

}

# private

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Project = var.project_name
  Environment = var.environment }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id
  tags = {
    Project = var.project_name
  Environment = var.environment }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "${var.region}a"
  tags = {
    Project = var.project_name
  Environment = var.environment }
}

resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "${var.region}c"
  tags = {
    Project = var.project_name
  Environment = var.environment }
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = {
    Project = var.project_name
  Environment = var.environment }
}

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id


}


resource "aws_route_table_association" "assoc_private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id

}

resource "aws_route_table_association" "assoc_private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private.id

}


