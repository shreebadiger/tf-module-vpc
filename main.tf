resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = merge(var.tags, {Name = var.env})
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet)
  vpc_id     = aws_vpc.main.id
  availability_zone = var.azs_subnet[count.index]
  cidr_block = var.public_subnet[count.index]
  tags = merge(var.tags, {Name = "public-subnet"})
}

resource "aws_subnet" "web" {
  count = length(var.web_subnet)
  vpc_id     = aws_vpc.main.id
  availability_zone = var.azs_subnet[count.index]
  cidr_block = var.web_subnet[count.index]
  tags = merge(var.tags, {Name = "web-subnet"})
}

resource "aws_subnet" "app" {
  count = length(var.app_subnet)
  vpc_id     = aws_vpc.main.id
  availability_zone = var.azs_subnet[count.index]
  cidr_block = var.app_subnet[count.index]
  tags = merge(var.tags, {Name = "app-subnet"})
}

resource "aws_subnet" "db" {
  count = length(var.db_subnet)
  vpc_id     = aws_vpc.main.id
  availability_zone = var.azs_subnet[count.index]
  cidr_block = var.db_subnet[count.index]
  tags = merge(var.tags, {Name = "db-subnet"})
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {Name = "public"})
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    cidr_block = var.default_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }
}

resource "aws_route_table" "web" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {Name = "web"})
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
   route {
    cidr_block = var.default_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }
}

resource "aws_route_table" "app" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {Name = "app"})
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
   route {
    cidr_block = var.default_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {Name = "db"})
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
   route {
    cidr_block = var.default_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "web" {
  count = length(aws_subnet.web)
  subnet_id      = aws_subnet.web.*.id[count.index]
  route_table_id = aws_route_table.web.id
}

resource "aws_route_table_association" "app" {
  count = length(aws_subnet.app)
  subnet_id      = aws_subnet.app.*.id[count.index]
  route_table_id = aws_route_table.app.id
}

resource "aws_route_table_association" "db" {
  count = length(aws_subnet.db)
  subnet_id      = aws_subnet.db.*.id[count.index]
  route_table_id = aws_route_table.db.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {Name = "igw"})
}
resource "aws_eip" "ngw" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw.id
  subnet_id     = aws_subnet.public.*.id[0]
  tags = merge(var.tags, {Name = "ngw"})
}

resource "aws_vpc_peering_connection" "peer" {
  peer_owner_id = var.account_id
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.main.id
  auto_accept = true
  tags = merge(var.tags, {Name = "peer-${var.env}-vpc to default-vpc"})
}

resource "aws_route" "default-vpc-peer-route" {
  route_table_id            = var.default_route_table_id
  destination_cidr_block    = var.vpc_cidr_block 
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}