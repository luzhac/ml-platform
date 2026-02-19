
output "challenge_dynamodb_table_name" {
  value = module.dynamodb.challenge_dynamodb_table_name
}

output "challenge_s3_name" {
  value = module.s3.s3_bucket_challenge_name
}
