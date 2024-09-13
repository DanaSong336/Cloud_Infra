# Load Balancer
resource "aws_lb" "app_lb" {
  name               = var.name
  internal           = false
  load_balancer_type = var.type
  security_groups    = var.security_group_ids
  subnets            = var.public_subnet_ids

  tags = {
    Name = var.tag
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = var.tg_name
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = var.tg_tag
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = var.tg_port
  protocol          = var.tg_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}