#!/bin/bash

NPM_ADDR="http://localhost:81"

RELEASE_FLAG="./hold-backend/tmp/release.flag"

# Load API Token and Proxy ID
API_TOKEN=$(cat api_token.txt)
PROXY_ID=$(cat proxy_id.txt)

if [[ -z "$API_TOKEN" || -z "$PROXY_ID" ]]; then
    echo "Error: API token or Proxy ID not found. Exiting..."
    exit 1
fi

hold_requests() {
  curl -s -X PUT "$NPM_ADDR/api/nginx/proxy-hosts/$PROXY_ID" \
       -H "Authorization: Bearer $API_TOKEN" \
       -H "Content-Type: application/json" \
       -d '{
             "forward_scheme": "http",
             "forward_host": "hold",
             "forward_port": 80,
             "enabled": true
           }' > /dev/null
  echo "Requests are now being held."
}

release_requests() {
  curl -s -X PUT "$NPM_ADDR/api/nginx/proxy-hosts/$PROXY_ID" \
       -H "Authorization: Bearer $API_TOKEN" \
       -H "Content-Type: application/json" \
       -d '{
             "forward_scheme": "http",
             "forward_host": "apache",
             "forward_port": 80,
             "enabled": true
           }' > /dev/null
  echo "Proxy configuration updated: Requests are now released."
}

# Step 1: Hold requests by pointing the proxy to the hold service

rm -f $RELEASE_FLAG
echo "Release flag removed. In-flight requests will now be held."

hold_requests
sleep 2  # Wait a moment to ensure the proxy applies the new configuration

# Step 2: Perform multiple deployment actions simultaneously
(
  echo "Updating timestamp..."
  echo "<html><body><h1>Deployment Test</h1><p>Updated Timestamp: $(date)</p></body></html>" > apache/html/index.html
) &

(
  echo "Restarting Apache..."
  docker restart $(docker ps -q --filter "name=apache")
) &

# simulate a 10 second delay on deployment task
(
    sleep 5
) &

# Wait for all parallel actions to finish before releasing
wait

# Step 3: Create release flag so that held requests are forwarded to Apache
touch $RELEASE_FLAG
echo "Release flag created. In-flight requests will now be released."

# Step 4: Update the proxy configuration to send new requests directly to Apache
release_requests