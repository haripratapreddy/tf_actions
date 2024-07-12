resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_subnet" "pub-subnet" {
  count      = length(var.pub_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.pub_subnet_cidr[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-pub-subnet-${count.index + 1}"
    Tier = "Public"
  }
}

resource "aws_subnet" "pri-subnet" {
  count      = length(var.pri_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.pri_subnet_cidr[count.index]

  tags = {
    Name = "${var.vpc_name}-pri-subnet-${count.index + 1}"
    Tier = "Private"
  }
}

# Public Route Table
resource "aws_route_table" "pub-rt" {
  vpc_id  = aws_vpc.main.id

  # since this is exactly the route AWS will create, the route will be adopted
  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-pub-rt"
  }
}

# EIP for the Nat Gateway
resource "aws_eip" "eip-nat" {
  count             = var.EIP ? 1 : 0  # Create EIP only if EIP is true
  domain            = "vpc"
  public_ipv4_pool  = "amazon"

  tags = {
    Name = "${var.vpc_name}-eip-nat-gateway"
  }
}

# Nat gateway
resource "aws_nat_gateway" "nat-gateway" {
  count = var.EIP ? 1 : 0  # Create AWS Nat Gateway only if EIP is true
  connectivity_type             = "public"
  allocation_id                 = aws_eip.eip-nat[count.index].id
  subnet_id                     = aws_subnet.pub-subnet[0].id
  tags = {
    Name = "${var.vpc_name}-nat-gateway"
  }
}

#Private route table
resource "aws_route_table" "pri-rt" {
  vpc_id  = aws_vpc.main.id

  # since this is exactly the route AWS will create, the route will be adopted
  # route {
  #   cidr_block = "0.0.0.0/0"
  #   # nat_gateway_id = aws_nat_gateway.nat-gateway.id
  # }
  tags = {
    Name = "${var.vpc_name}-pri-rt"
  }
}

resource "aws_route" "nat-access" {
  count                   = var.EIP ? 1 : 0  # Creates a private route only if EIP is true
  route_table_id          = aws_route_table.pri-rt.id
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id          = aws_nat_gateway.nat-gateway[count.index].id
}

resource "aws_route_table_association" "pub-rt-as" {
  count          = length(var.pub_subnet_cidr)
  subnet_id      = element(aws_subnet.pub-subnet[*].id, length([aws_subnet.pub-subnet[*]])-1)
  route_table_id = aws_route_table.pub-rt.id
}

resource "aws_route_table_association" "pri-rt-as" {
  count          = length(var.pri_subnet_cidr)
  subnet_id      = element(aws_subnet.pri-subnet[*].id, length([aws_subnet.pri-subnet[*]])-1)
  route_table_id = aws_route_table.pri-rt.id
}

output "pub_subnet" {
  value = aws_subnet.pub-subnet[*].id
}

output "pri_subnet" {
  value = aws_subnet.pri-subnet[*].id
}
