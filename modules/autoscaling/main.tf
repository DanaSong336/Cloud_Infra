# Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  launch_template {
    id      = var.lt_id
    version = "$Latest"
  }
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.public_subnet_ids
  health_check_type   = var.health_check_type
  tag {
    key                 = var.key
    value               = var.value
    propagate_at_launch = true
  }

  # Autoscaling Group에 Target Group을 연결합니다.
  target_group_arns = var.target_group_arns
}