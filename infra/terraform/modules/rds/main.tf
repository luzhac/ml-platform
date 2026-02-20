resource "aws_db_subnet_group" "mlflow" {
  name       = "${var.project_name}-mlflow-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "mlflow_rds" {
  name   = "${var.project_name}-mlflow-rds-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups =[ var.rds_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "mlflow" {
  identifier              = "${var.project_name}-mlflow-db"
  engine                  = "postgres"
  engine_version          = "15"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  username                = var.mlflow_db_username
  password                = var.mlflow_db_password
  db_name                 = "mlflow"
  skip_final_snapshot     = false
  publicly_accessible     = false
  vpc_security_group_ids  = [aws_security_group.mlflow_rds.id]
  db_subnet_group_name    = aws_db_subnet_group.mlflow.name
  backup_retention_period = 7
  multi_az                = false
}