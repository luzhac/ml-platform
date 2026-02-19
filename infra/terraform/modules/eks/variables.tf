variable "environment" {
  description = "Environment"
  type        = string
}

variable "project_name" {
  description = "project_name"
  type        = string
}

variable "region" { type = string }

variable "cluster_role_arn" {
  description = "cluster_role_arn"
  type        = string
}

variable "node_role_arn" {
  description = "node_role_arn"
  type        = string
}


variable "subnet_ids" {
  description = "subnet_ids"
  type        = list(string)
}

 


