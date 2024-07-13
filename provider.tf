provider "aws" {
  access_key                  = "testKey"
  secret_key                  = "testSecret"
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2        = "http://localhost:4566"
    s3         = "http://localhost:4566"
    rds        = "http://localhost:4566"
    iam        = "http://localhost:4566"
    cloudwatch = "http://localhost:4566"
    lambda     = "http://localhost:4566"
    apigateway = "http://localhost:4566"
  }
}