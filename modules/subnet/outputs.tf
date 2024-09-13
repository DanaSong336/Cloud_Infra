output "subnet_ids" {
  value = values(aws_subnet.subnets)[*].id
}