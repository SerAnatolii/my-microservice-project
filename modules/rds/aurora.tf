
resource "aws_rds_cluster" "main" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier      = var.db_identifier
  engine                  = var.engine
  engine_version          = var.engine_version
  database_name           = var.db_name
  master_username         = var.db_username
  master_password         = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.main.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name
  skip_final_snapshot     = var.skip_final_snapshot

  tags = {
    Name = var.db_identifier
  }
}

resource "aws_rds_cluster_instance" "writer" {
  count = var.use_aurora ? 1 : 0

  cluster_identifier   = aws_rds_cluster.main[0].id
  identifier           = "${var.db_identifier}-writer"
  instance_class       = var.instance_class
  engine               = var.engine
  engine_version       = var.engine_version
  publicly_accessible  = var.publicly_accessible
}