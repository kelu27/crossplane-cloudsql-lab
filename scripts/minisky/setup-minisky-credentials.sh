#!/bin/bash

set -euo pipefail

TOKEN=${1:-minisky-local-token}

kubectl create secret generic gcp-credentials \
  --namespace crossplane-system \
  --from-literal=creds="$TOKEN" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "MiniSky access token secret 'gcp-credentials' created in namespace 'crossplane-system'"