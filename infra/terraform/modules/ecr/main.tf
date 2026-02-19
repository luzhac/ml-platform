resource "aws_ecr_repository" "challenge_repo" {
  name                 = "marscompute-ml"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}