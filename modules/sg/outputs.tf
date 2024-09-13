output "sg_ids" {
  description = "List of all security group IDs"
  value       = { for key, sg in aws_security_group.sg : key => sg.id }
}
