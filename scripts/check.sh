#!/bin/bash
# Quick sanity check script — run this at any point to see where you are

echo "=== Cluster ==="
kubectl get nodes

echo ""
echo "=== Crossplane pods ==="
kubectl get pods -n crossplane-system

echo ""
echo "=== Providers ==="
kubectl get providers 2>/dev/null || echo "No providers found yet"

echo ""
echo "=== ProviderConfigs ==="
kubectl get providerconfigs 2>/dev/null || echo "No ProviderConfigs found yet"

echo ""
echo "=== XRDs ==="
kubectl get xrds 2>/dev/null || echo "No XRDs found yet"

echo ""
echo "=== Compositions ==="
kubectl get compositions 2>/dev/null || echo "No Compositions found yet"

echo ""
echo "=== Claims ==="
kubectl get postgresqlinstance -A 2>/dev/null || echo "No claims found yet"

echo ""
echo "=== Managed Resources ==="
kubectl get managed 2>/dev/null || echo "No managed resources found yet"