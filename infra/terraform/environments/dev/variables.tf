variable "region" {
  description = "AWS region to deploy"
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Prefix for all resources"
  type        = string
  default     = "ml"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

 variable "namespace" {
  description = "namespace"
  type        = string
  default     = "ml-dev"
}

 variable "pipeline_namespace" {
  description = "pipeline_namespace"
  type        = string
  default     = "pipeline"
}

 variable "pipeline_service_account" {
  description = "pipeline_service_account"
  type        = string
  default     = "pipeline-sa"
}

variable "mlflow_db_username" {
  type = string
}

variable "mlflow_db_password" {
  type      = string
  sensitive = true
}
