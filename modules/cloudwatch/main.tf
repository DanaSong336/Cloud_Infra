# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "web_instance_logs" {
  name = var.log_group_name
}

resource "aws_cloudwatch_log_stream" "web_instance_log_stream" {
  name           = var.log_stream_name
  log_group_name = aws_cloudwatch_log_group.web_instance_logs.name
}

# Auto Scaling Group Capacity Alarm
resource "aws_cloudwatch_metric_alarm" "asg_capacity_alarm" {
  alarm_name                = var.alarm_name
  comparison_operator       = var.comparison_operator
  evaluation_periods        = var.evaluation_periods
  metric_name               = var.metric_name
  namespace                 = var.namespace
  period                    = var.period
  statistic                 = var.statistic
  threshold                 = var.threshold
  alarm_description         = var.description
  insufficient_data_actions = []

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  actions_enabled = false
}

# RDS CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "rds_cpu_alarm" {
  alarm_name                = var.alarm_name_rds
  comparison_operator       = var.comparison_operator_rds
  evaluation_periods        = var.evaluation_periods_rds
  metric_name               = var.metric_name_rds
  namespace                 = var.namespace_rds
  period                    = var.period_rds
  statistic                 = var.statistic_rds
  threshold                 = var.threshold_rds
  alarm_description         = var.description_rds
  insufficient_data_actions = []

  dimensions = {
    DBInstanceIdentifier = var.rds_mysql_id
  }

  actions_enabled = false
}