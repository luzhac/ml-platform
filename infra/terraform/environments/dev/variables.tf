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
