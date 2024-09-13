# Launch Template
resource "aws_launch_template" "web_lt" {
  name          = var.name
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    security_groups             = var.security_group_ids
    associate_public_ip_address = true
    subnet_id                   = var.public_subnet_id
  }

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  user_data = var.user_data

  lifecycle {
    create_before_destroy = true
  }
}