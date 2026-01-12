output "repo_arn" {
    value = aws_ecr_repository.app_ecr.arn
}

output "registry_id" {
    value = aws_ecr_repository.app_ecr.registry_id
}

output "registry_url" {
    value = aws_ecr_repository.app_ecr.repository_url
}

