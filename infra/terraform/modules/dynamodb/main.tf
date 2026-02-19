resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name         = "Challenge"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "email"


  attribute {
    name = "email"
    type = "S"
  }


  tags = {
    Project = var.project_name
  Environment = var.environment }

}