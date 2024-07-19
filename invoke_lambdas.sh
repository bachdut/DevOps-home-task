#!/bin/sh

# Fetch the invoke URL from the Terraform output
INVOKE_URL=$(terraform output -raw invoke_url)

# Call the first lambda function
RESPONSE_FIRST=$(curl -s ${INVOKE_URL}/first)
echo "First Lambda Response: $RESPONSE_FIRST"

# Extract the timestamp from the first lambda response
TIMESTAMP=$(echo "$RESPONSE_FIRST" | perl -nle 'print $1 if /epoch value of (.*) GMT/')
echo "Extracted TIMESTAMP: $TIMESTAMP"

# Manually parse and convert the timestamp to epoch
YEAR=$(echo "$TIMESTAMP" | cut -d'.' -f3 | cut -d' ' -f1)
MONTH=$(echo "$TIMESTAMP" | cut -d'.' -f2)
DAY=$(echo "$TIMESTAMP" | cut -d'.' -f1)
TIME=$(echo "$TIMESTAMP" | cut -d' ' -f2)
AMPM=$(echo "$TIMESTAMP" | cut -d' ' -f3)

HOUR=$(echo "$TIME" | cut -d':' -f1)
MINUTE=$(echo "$TIME" | cut -d':' -f2)
SECOND=$(echo "$TIME" | cut -d':' -f3)

# Adjust hour for AM/PM
if [ "$AMPM" = "PM" ] && [ "$HOUR" -ne 12 ]; then
  HOUR=$((HOUR + 12))
fi
if [ "$AMPM" = "AM" ] && [ "$HOUR" -eq 12 ]; then
  HOUR=0
fi

# Use date command to calculate the epoch time
FORMATTED_TIMESTAMP="${YEAR}-${MONTH}-${DAY} ${HOUR}:${MINUTE}:${SECOND}"
AUTH_VALUE=$(date -u -d "$FORMATTED_TIMESTAMP" +%s)
echo "Converted AUTH_VALUE to epoch: $AUTH_VALUE"

# Make the second lambda call with the Authorization header
RESPONSE_SECOND=$(curl -s -H "Authorization: ${AUTH_VALUE}" ${INVOKE_URL}/second)
echo "Second Lambda Response: $RESPONSE_SECOND"