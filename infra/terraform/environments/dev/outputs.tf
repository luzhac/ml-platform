
output "challenge_dynamodb_table_name" {
  value = module.dynamodb.challenge_dynamodb_table_name
}

output "challenge_s3_name" {
  value = module.s3.s3_bucket_challenge_name
}
output "mlflow_role" {
 value=module.iam_oidc.mlflow_irsa_role_arn

 }

output "ml_s3_name" {
  value = module.s3.s3_bucket_ml_name
}

output "mlflow_rds_endpoint" {
 value=module.mlflow_rds.mlflow_rds_endpoint

 }

 