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

 