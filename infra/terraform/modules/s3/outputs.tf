
output "s3_bucket_challenge_name" {
  value = aws_s3_bucket.s3_challenge.bucket
}

output "s3_bucket_challenge_arn" {
  value = aws_s3_bucket.s3_challenge.arn
}
