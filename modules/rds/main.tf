# RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = var.sg_name
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = var.sg_name
  }
}

resource "aws_db_instance" "rds_mysql" {
  allocated_storage      = var.storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.class
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  parameter_group_name   = var.parameter_group_name
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = var.vpc_security_group_ids
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = {
    Name = var.tag
  }
}