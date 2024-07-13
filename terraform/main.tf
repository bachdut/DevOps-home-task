# Configure the AWS provider to use LocalStack
provider "aws" {
  access_key                  = "test"
  secret_key                  = "test"
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  endpoints {
    lambda     = "http://localhost:4566"
    apigateway = "http://localhost:4566"
    iam        = "http://localhost:4566"
    logs       = "http://localhost:4566"
  }
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  # IAM role policy that allows the Lambda service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Deploy the first Lambda function using the Docker image
resource "aws_lambda_function" "first_lambda" {
  function_name = "firstLambdaFunction"
  package_type  = "Image"
  image_uri     = "jonathanpick/first-lambda:v1"
  role          = aws_iam_role.lambda_role.arn
}

# Create an API Gateway REST API
resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "test-api"
  description = "API Gateway for Lambda functions"
}

# Create a resource in the API Gateway for the first Lambda function
resource "aws_api_gateway_resource" "lambda_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "first"  # This creates the /first path
}

# Create an HTTP GET method for the Lambda resource
resource "aws_api_gateway_method" "lambda_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.lambda_resource.id
  http_method   = "GET"
  authorization = "NONE"  # No authorization required
}

# Integrate the API Gateway method with the Lambda function
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.lambda_resource.id
  http_method             = aws_api_gateway_method.lambda_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.first_lambda.invoke_arn  # Links to the Lambda function
}

# Deploy the API Gateway and create a stage
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [aws_api_gateway_integration.lambda_integration]  # Ensure integration is created first
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = "test"  # Stage name (e.g., /test)
}

# Output the invoke URL of the API Gateway
output "invoke_url" {
  value = aws_api_gateway_deployment.api_deployment.invoke_url
}