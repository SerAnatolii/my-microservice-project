# Урок 10: # Модуль RDS для Terraform

Цей модуль створює універсальну базу даних на AWS: або Aurora Cluster (з одним writer-інстансом), або звичайну RDS-інстанс, залежно від значення змінної `use_aurora`. Він автоматично створює DB Subnet Group, Security Group та Parameter Group з базовими параметрами (max_connections, log_statement, work_mem).

Модуль підтримує багаторазове використання з мінімальними змінами змінних і може бути легко адаптований для різних типів БД (наприклад, PostgreSQL, MySQL).

## Приклад використання модуля

У вашому `main.tf` додайте наступне:

```terraform
module "rds" {
  source = "./modules/rds"

  use_aurora             = true  # true для Aurora Cluster, false для RDS instance
  db_identifier          = "my-db"
  engine                 = "postgres"
  engine_version         = "13.6"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "mydatabase"
  db_username            = "admin"
  db_password            = "strongpassword"
  subnet_ids             = ["subnet-12345678", "subnet-87654321"]  # IDs підмереж з VPC
  vpc_id                 = "vpc-12345678"
  db_port                = 5432
  allowed_cidr_blocks    = ["10.0.0.0/16"]  # CIDR для доступу до БД
  parameter_group_family = "postgres13"
  max_connections        = "100"
  log_statement          = "all"
  work_mem               = "4096"
  multi_az               = true
  publicly_accessible    = false
  skip_final_snapshot    = true
}