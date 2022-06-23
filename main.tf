data "aws_caller_identity" "current" {}

data "aws_db_instance" "target" {
  db_instance_identifier = var.db_instance
}

resource "aws_sns_topic" "alarms" {
  name = "${data.aws_db_instance.target.db_name}-alarms-topic"
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space" {
  alarm_name        = "${data.aws_db_instance.target.db_name} FreeStorageSpace <= 20480"
  alarm_description = "Alert when FreeStorageSpace <= 20480, 1 time within 1 minute"
  namespace         = "AWS/RDS"
  dimensions        = {
    ClientId   = data.aws_caller_identity.current.account_id
    DomainName = data.aws_db_instance.target.db_name
  }
  statistic           = "Minimum"
  metric_name         = "FreeStorageSpace"
  comparison_operator = "LessThanOrEqualToThreshold"
  threshold           = var.free_storage_space_threshold 
  period              = 60
  evaluation_periods  = 1
  ok_actions          = [
    aws_sns_topic.alarms.arn
  ]
  alarm_actions = [
    aws_sns_topic.alarms.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name        = "${data.aws_db_instance.target.db_name} CPUUtilization >= ${var.cpu_utilization_threshold}"
  alarm_description = "Alert when CPUUtilization >=${var.cpu_utilization_threshold}, ${var.cpu_utilization_evaluation_periods} time within ${var.cpu_utilization_period} seconds"
  namespace         = "AWS/RDS"
  dimensions        = {
    ClientId   = data.aws_caller_identity.current.account_id
    DomainName = data.aws_db_instance.target.db_name
  }
  statistic           = "Maximum"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = var.cpu_utilization_threshold
  period              = var.cpu_utilization_period
  evaluation_periods  = var.cpu_utilization_evaluation_periods
  ok_actions          = [
    aws_sns_topic.alarms.arn
  ]
  alarm_actions = [
    aws_sns_topic.alarms.arn
  ]
}
