resource "aws_api_gateway_rest_api" "MyDemoAPI" {
  name        = "MyDemoAPI"
  description = "Bar's API"
}

# first lambda configuration

resource "aws_api_gateway_resource" "FirstLambdaResource" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  parent_id   = aws_api_gateway_rest_api.MyDemoAPI.root_resource_id
  path_part   = "first"
}

resource "aws_api_gateway_method" "FirstLambdaMethod" {
  rest_api_id   = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id   = aws_api_gateway_resource.FirstLambdaResource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "FirstLambdaIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id             = aws_api_gateway_resource.FirstLambdaResource.id
  http_method             = aws_api_gateway_method.FirstLambdaMethod.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.first_lambda.invoke_arn
}

resource "aws_lambda_permission" "FirstLambdaPermission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.first_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.MyDemoAPI.execution_arn}/*/*/*"
}

# second lambda configuration

resource "aws_api_gateway_resource" "SecondLambdaResource" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  parent_id   = aws_api_gateway_rest_api.MyDemoAPI.root_resource_id
  path_part   = "second"
}

resource "aws_api_gateway_method" "SecondLambdaMethod" {
  rest_api_id   = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id   = aws_api_gateway_resource.SecondLambdaResource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "SecondLambdaIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id             = aws_api_gateway_resource.SecondLambdaResource.id
  http_method             = aws_api_gateway_method.SecondLambdaMethod.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.second_lambda.invoke_arn
}

resource "aws_lambda_permission" "SecondLambdaPermission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.second_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.MyDemoAPI.execution_arn}/*/*/*"
}

resource "aws_api_gateway_deployment" "MyDemoDeployment" {
  depends_on = [
    aws_api_gateway_integration.FirstLambdaIntegration,
    aws_api_gateway_integration.SecondLambdaIntegration
  ]
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  stage_name  = "test"
}

#outputs the url for the script to execute the lambdas

output "invoke_url" {
  value = "http://localhost:4566/restapis/${aws_api_gateway_rest_api.MyDemoAPI.id}/${aws_api_gateway_deployment.MyDemoDeployment.stage_name}/_user_request_"
}