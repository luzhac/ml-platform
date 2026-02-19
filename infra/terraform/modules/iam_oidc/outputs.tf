
output "service_account_role_arn" {
  value = aws_iam_role.ebs_csi_role.arn
}
