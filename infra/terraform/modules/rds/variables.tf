variable "region" { type = string }
variable "environment" {
  description = "Environment"
  type        = string
}

variable "project_name" {
  description = "project_name"
  type        = string
}

variable "mlflow_db_username" {
  description = "mlflow_db_username"
  type        = string
}

variable "mlflow_db_password" {
  description = "mlflow_db_password"
  type        = string
}

variable "private_subnet_ids" {
  
}

variable "rds_sg_id" {}
variable "vpc_id" {}
 
 