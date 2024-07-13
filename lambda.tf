resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
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

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "first_lambda" {
  function_name = "firstLambdaFunction"
  package_type  = "Image"
  image_uri     = "jonathanpick/first-lambda:v1"
  role          = aws_iam_role.lambda_role.arn
}

resource "aws_lambda_function" "second_lambda" {
  function_name = "secondLambdaFunction"
  package_type  = "Image"
  image_uri     = "jonathanpick/second-lambda:v1"
  role          = aws_iam_role.lambda_role.arn
}