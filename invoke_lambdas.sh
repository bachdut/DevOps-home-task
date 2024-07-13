#!/bin/sh

# URL for API Gateway (taken from the terraform output)
BASE_URL=$(terraform output -raw invoke_url)

echo "Base URL: $BASE_URL"

# Invoke the first Lambda function and capture the hint response
RESPONSE_FIRST=$(curl -s "${BASE_URL}/first")
echo "Response from first Lambda function: $RESPONSE_FIRST"

# Invoke the second Lambda function and capture the secret response
RESPONSE_SECOND=$(curl -s "${BASE_URL}/second")
echo "Response from second Lambda function: $RESPONSE_SECOND"