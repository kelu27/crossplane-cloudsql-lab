#!/bin/bash
# Usage: ./scripts/gcp/setup-gcp-credentials.sh /path/to/gcp-key.json

set -e

KEY_FILE=$1

if [ -z "$KEY_FILE" ]; then
  echo "Usage: $0 /path/to/gcp-key.json"
  exit 1
fi

if [ ! -f "$KEY_FILE" ]; then
  echo "Error: file not found: $KEY_FILE"
  exit 1
fi

kubectl create secret generic gcp-credentials \
  --namespace crossplane-system \
  --from-file=creds="$KEY_FILE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secret 'gcp-credentials' created in namespace 'crossplane-system'"