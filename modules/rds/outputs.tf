# lesson-7/modules/rds/outputs.tf

output "db_endpoint" {
  description = "Database endpoint"
  value = var.use_aurora ? aws_rds_cluster.main[0].endpoint : aws_db_instance.main[0].endpoint
}

output "db_arn" {
  description = "Database ARN"
  value = var.use_aurora ? aws_rds_cluster.main[0].arn : aws_db_instance.main[0].arn
}

output "subnet_group_name" {
  description = "DB subnet group name"
  value = aws_db_subnet_group.main.name
}

output "security_group_id" {
  description = "Security group ID"
  value = aws_security_group.main.id
}

output "parameter_group_name" {
  description = "Parameter group name"
  value = var.use_aurora ? aws_rds_cluster_parameter_group.main[0].name : aws_db_parameter_group.main[0].name
}