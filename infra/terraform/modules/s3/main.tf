# for app use
resource "aws_s3_bucket" "s3_challenge" {
  bucket = "marscompute-s3-ml"
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }

  lifecycle {
    prevent_destroy = false # 
  }

}

resource "aws_s3_bucket_versioning" "versioning_s3_for_challenge" {
  bucket = aws_s3_bucket.s3_challenge.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "challenge_ownership" {
  bucket = aws_s3_bucket.s3_challenge.id

  rule {
    object_ownership = "ObjectWriter"
  }
}


resource "aws_s3_bucket_public_access_block" "challenge_public_access" {
  bucket = aws_s3_bucket.s3_challenge.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = true
  restrict_public_buckets = true
}

# for mlflow use
resource "aws_s3_bucket" "mlflow_artifacts" {
  bucket = "${var.project_name}-marscompute-mlflow-artifacts"

  force_destroy = false
}

resource "aws_s3_bucket_versioning" "mlflow_versioning" {
  bucket = aws_s3_bucket.mlflow_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mlflow_sse" {
  bucket = aws_s3_bucket.mlflow_artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

 
