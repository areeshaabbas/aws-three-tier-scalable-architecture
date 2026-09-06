resource "aws_db_subnet_group" "subnet-grp" {
  name = "rds-subnet-grp"

  subnet_ids = [
    aws_subnet.private-1.id,
    aws_subnet.private-2.id
  ]

  tags = {
    Name = "rds-grp"
  }

}

resource "aws_db_instance" "db" {
  allocated_storage           = var.db_allocated_storage
  engine                      = "mysql"
  engine_version              = var.db_engine_version
  instance_class              = var.db_instance_class
  db_name                     = var.db_name
  username                    = var.db_username
  manage_master_user_password = true
  db_subnet_group_name        = aws_db_subnet_group.subnet-grp.name
  vpc_security_group_ids      = [aws_security_group.rds-sg.id]
  skip_final_snapshot         = true
  storage_encrypted           = true
  copy_tags_to_snapshot       = true
  backup_retention_period     = 7

  tags = {
    Name = "main-rds"
  }

}

