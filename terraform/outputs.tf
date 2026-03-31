output "dynamodb_table" {
  value = aws_dynamodb_table.url_table.name
}

output "create_lambda" {
  value = aws_lambda_function.create_url.function_name
}

output "redirect_lambda" {
  value = aws_lambda_function.redirect_url.function_name
}

output "api_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}

output "frontend_url" {
  value = aws_cloudfront_distribution.frontend.domain_name
}