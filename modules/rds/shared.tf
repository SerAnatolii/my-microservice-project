
resource "aws_db_subnet_group" "main" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.db_identifier}-subnet-group"
  }
}

resource "aws_security_group" "main" {
  name        = "${var.db_identifier}-sg"
  description = "Security group for RDS/Aurora"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.db_identifier}-sg"
  }
}

resource "aws_db_parameter_group" "main" {
  count = var.use_aurora ? 0 : 1

  name   = "${var.db_identifier}-param-group"
  family = var.parameter_group_family

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }

  parameter {
    name  = "log_statement"
    value = var.log_statement
  }

  parameter {
    name  = "work_mem"
    value = var.work_mem
  }

  tags = {
    Name = "${var.db_identifier}-param-group"
  }
}

resource "aws_rds_cluster_parameter_group" "main" {
  count = var.use_aurora ? 1 : 0

  name   = "${var.db_identifier}-cluster-param-group"
  family = var.parameter_group_family

  parameter {
    name  = "max_connections"
    value = var.max_connections
  }

  parameter {
    name  = "log_statement"
    value = var.log_statement
  }

  parameter {
    name  = "work_mem"
    value = var.work_mem
  }

  tags = {
    Name = "${var.db_identifier}-cluster-param-group"
  }
}