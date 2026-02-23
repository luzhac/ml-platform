variable "environment" {
  description = "Environment"
  type        = string
}

variable "project_name" {
  description = "project_name"
  type        = string
}
variable "region" { type = string }


variable "namespace" { type = string }

variable "dynamodb_arn" { type = string }
variable "s3_arn" { type = string }
variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "pipeline_service_account" {}
variable "pipeline_namespace" {}

variable "inference_namespace" {}
variable "inference_service_account" {}

variable "mlflow_s3_arn" {}
 

 