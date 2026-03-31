terraform {
  backend "s3" {
    bucket         = "enterprise-url-shortener-terraform-state"
    key            = "terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = "enterprise-url-shortener-lock"
    encrypt        = true
  }
}