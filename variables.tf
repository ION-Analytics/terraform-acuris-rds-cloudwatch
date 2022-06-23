variable "db_instance" {
  type = string
}

# disk usage threshold, in kilobytes
variable "free_storage_space_threshold" {
  type = string
  default = 20480  # 20 megabytes.  might want to adjust based on actual storage amount
}

# cpu utilization percentage threshold
variable "cpu_utilization_threshold" {
  type = string
  default = 80
}

# duration in minutes of sampling period for cpu utilization check
variable "cpu_utilization_period" {
  type = string
  default = 30
}

# number of cpu_utilization_periods exceeding cpu_utilization_threshold before triggering alarm
variable "cpu_utilization_evaluation_periods" {
  type = string
  default = 3
}
