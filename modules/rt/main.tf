# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.cidr_block
    gateway_id = var.igw_id
  }

  tags = {
    Name = var.name
  }
}

# Route Table Associations
resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = var.public_subnet_1_id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = var.public_subnet_2_id
  route_table_id = aws_route_table.public_rt.id
}
