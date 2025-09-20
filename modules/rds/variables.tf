# lesson-7/modules/rds/variables.tf

variable "use_aurora" {
  description = "Whether to use Aurora Cluster (true) or single RDS instance (false)"
  type        = bool
  default     = false
}

variable "db_identifier" {
  description = "Identifier for the RDS instance or Aurora cluster"
  type        = string
}

variable "engine" {
  description = "Database engine (e.g., postgres, mysql)"
  type        = string
}

variable "engine_version" {
  description = "Database engine version"
  type        = string
}

variable "instance_class" {
  description = "Instance class for RDS or Aurora"
  type        = string
}

variable "allocated_storage" {
  description = "Allocated storage in GB (for non-Aurora)"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Storage type (for non-Aurora)"
  type        = string
  default     = "gp2"
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database admin username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
}

variable "subnet_ids" {
  description = "List of subnet IDs for DB subnet group"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432  # Default for PostgreSQL
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the DB"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Adjust for security
}

variable "parameter_group_family" {
  description = "Parameter group family (e.g., postgres13)"
  type        = string
}

variable "max_connections" {
  description = "Max connections parameter"
  type        = string
  default     = "100"
}

variable "log_statement" {
  description = "Log statement parameter"
  type        = string
  default     = "all"
}

variable "work_mem" {
  description = "Work mem parameter"
  type        = string
  default     = "4096"
}

variable "multi_az" {
  description = "Enable multi-AZ deployment"
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Make the DB publicly accessible"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = true
}