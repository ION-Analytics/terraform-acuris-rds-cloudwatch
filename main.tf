data "aws_caller_identity" "current" {}

data "aws_db_instance" "target" {
  db_instance_identifier = var.db_instance
}

resource "aws_sns_topic" "alarms" {
  name = "${data.aws_db_instance.target.db_instance_identifier}-alarms-topic"
}

locals {
  cluster_dimension = tomap({DBClusterIdentifier = data.aws_db_instance.target.db_cluster_identifier})
  noncluster_dimension = tomap({DBInstanceIdentifier = data.aws_db_instance.target.db_instance_identifier})
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space" {
  alarm_name        = "${data.aws_db_instance.target.db_instance_identifier} FreeStorageSpace <= 20480"
  alarm_description = "Alert when FreeStorageSpace <= 20480, 1 time within 1 minute"
  namespace         = "AWS/RDS"
  dimensions        = startswith(data.aws_db_instance.target.engine,"aurora") ? local.cluster_dimension : local.noncluster_dimension
  statistic           = "Minimum"
  metric_name         = startswith(data.aws_db_instance.target.engine,"aurora") ? "FreeLocalStorage" : "FreeStorageSpace"
  comparison_operator = "LessThanOrEqualToThreshold"
  threshold           = var.free_storage_space_threshold 
  period              = var.free_storage_space_period
  evaluation_periods  = var.free_storage_space_evaluation_periods
  treat_missing_data  = "ignore"
  ok_actions          = [
    aws_sns_topic.alarms.arn
  ]
  alarm_actions = [
    aws_sns_topic.alarms.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name        = "${data.aws_db_instance.target.db_instance_identifier} CPUUtilization >= ${var.cpu_utilization_threshold}"
  alarm_description = "Alert when CPUUtilization >=${var.cpu_utilization_threshold}, ${var.cpu_utilization_evaluation_periods} time within ${var.cpu_utilization_period} seconds"
  namespace         = "AWS/RDS"
  dimensions        = startswith(data.aws_db_instance.target.engine,"aurora") ? local.cluster_dimension : local.noncluster_dimension
  statistic           = "Maximum"
  metric_name         = "CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = var.cpu_utilization_threshold
  period              = var.cpu_utilization_period
  evaluation_periods  = var.cpu_utilization_evaluation_periods
  treat_missing_data  = "ignore"
  ok_actions          = [
    aws_sns_topic.alarms.arn
  ]
  alarm_actions = [
    aws_sns_topic.alarms.arn
  ]
}
