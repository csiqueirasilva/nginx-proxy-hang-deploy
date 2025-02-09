#!/bin/bash

NPM_IP="localhost"
ADMIN_EMAIL="admin@example.com"
ADMIN_PASSWORD="changeme"

echo "Waiting for Nginx Proxy Manager to start..."
until curl -s -o /dev/null "http://$NPM_IP:81"; do
  sleep 3
  echo "Waiting for NPM..."
done

echo "Getting API Token..."
API_RESPONSE=$(curl -s -X POST "http://$NPM_IP:81/api/tokens" \
     -H "Content-Type: application/json" \
     -d "{
           \"identity\": \"$ADMIN_EMAIL\",
           \"secret\": \"$ADMIN_PASSWORD\"
         }")

# API_TOKEN is a JWT token that expires in 1 day; would renew every 12 hours in a separate script
API_TOKEN=$(echo "$API_RESPONSE" | jq -r .token)

if [[ "$API_TOKEN" == "null" || -z "$API_TOKEN" ]]; then
    echo "Failed to retrieve API token. Exiting..."
    exit 1
fi

echo "Creating Proxy for Apache..."
PROXY_RESPONSE=$(curl -s -X POST "http://$NPM_IP:81/api/nginx/proxy-hosts" \
     -H "Authorization: Bearer $API_TOKEN" \
     -H "Content-Type: application/json" \
     -d "{
           \"domain_names\": [\"localhost\"],
           \"forward_scheme\": \"http\",
           \"forward_host\": \"apache\",
           \"forward_port\": 80,
           \"enabled\": true
         }")

PROXY_ID=$(echo "$PROXY_RESPONSE" | jq -r .id)

if [[ "$PROXY_ID" == "null" || -z "$PROXY_ID" ]]; then
    echo "Failed to create proxy. Exiting..."
    exit 1
fi

echo "Proxy created with ID: $PROXY_ID"
echo "$API_TOKEN" > api_token.txt
echo "$PROXY_ID" > proxy_id.txt
