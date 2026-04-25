#!/usr/bin/env bash
# Test the lead capture webhook
# Usage: bash examples/test-curl.sh https://your-n8n-domain.com

set -e

BASE_URL="${1:-http://localhost:5678}"
WEBHOOK_PATH="/webhook/new-lead"
URL="${BASE_URL}${WEBHOOK_PATH}"

echo "Testing webhook at: ${URL}"
echo "---"

curl -X POST "${URL}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Client",
    "email": "test@example.com",
    "project_type": "Telegram Bot Development",
    "budget": "$500"
  }' \
  -w "\n---\nHTTP Status: %{http_code}\nTotal Time: %{time_total}s\n"
