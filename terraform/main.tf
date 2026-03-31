provider "aws" {
  region = var.aws_region
}

# DynamoDB Table
resource "aws_dynamodb_table" "url_table" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "short_code"

  attribute { name = "short_code", type = "S" }
}

# Lambda Role
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{ Action="sts:AssumeRole", Effect="Allow", Principal={Service="lambda.amazonaws.com"}}]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda Functions
resource "aws_lambda_function" "create_url" {
  function_name = "${var.project_name}-create"
  filename      = "create_url.zip"
  handler       = "create_url.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      TABLE_NAME = var.table_name
      API_BASE   = var.api_base
    }
  }
}

resource "aws_lambda_function" "redirect_url" {
  function_name = "${var.project_name}-redirect"
  filename      = "redirect_url.zip"
  handler       = "redirect_url.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      TABLE_NAME = var.table_name
      API_BASE   = var.api_base
    }
  }
}

# API Gateway
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "create_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.create_url.invoke_arn
}

resource "aws_apigatewayv2_integration" "redirect_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.redirect_url.invoke_arn
}

resource "aws_apigatewayv2_route" "create_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /create"
  target    = "integrations/${aws_apigatewayv2_integration.create_integration.id}"
}

resource "aws_apigatewayv2_route" "redirect_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /{code}"
  target    = "integrations/${aws_apigatewayv2_integration.redirect_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

# Lambda Permissions
resource "aws_lambda_permission" "api_create" {
  statement_id  = "AllowAPIGatewayInvokeCreate"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_url.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "api_redirect" {
  statement_id  = "AllowAPIGatewayInvokeRedirect"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.redirect_url.function_name
  principal     = "apigateway.amazonaws.com"
}

# S3 Frontend
resource "aws_s3_bucket" "frontend" {
  bucket = var.frontend_bucket
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "frontend" {
  origin {
    domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.frontend.id}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.frontend.id}"

    forwarded_values {
      query_string = true
      cookies { forward="none" }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate { cloudfront_default_certificate = true }
}