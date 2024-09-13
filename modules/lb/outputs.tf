output "app_tg_arn" {
  value = aws_lb_target_group.app_tg.arn
}

output "lb_dns" {
  value = aws_lb.app_lb.dns_name
}