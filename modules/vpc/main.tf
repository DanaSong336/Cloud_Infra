# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = var.name
  }
}
