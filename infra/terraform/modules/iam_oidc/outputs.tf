
output "csi_service_account_role_arn" {
  value = aws_iam_role.ebs_csi_role.arn
}

output "as_service_account_role_arn" {
  value = aws_iam_role.autoscaler_role.arn
}

output "mlflow_irsa_role_arn" {
  value = aws_iam_role.mlflow_irsa.arn
}
