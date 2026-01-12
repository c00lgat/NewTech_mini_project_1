resource "aws_ecr_repository" "app_ecr" {
  name                 = var.repo_name
  image_tag_mutability = "MUTABLE"
}