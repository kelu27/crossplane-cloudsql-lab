#!/bin/bash
# Quick sanity check script — run this at any point to see where you are

echo "=== Cluster ==="
kubectl get nodes

echo ""
echo "=== Crossplane pods ==="
kubectl get pods -n crossplane-system

echo ""
echo "=== Functions ==="
kubectl get functions,functionrevisions -A 2>/dev/null || echo "No functions found yet"

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
echo "=== Composite Resources ==="
kubectl get xpostgresqlinstances 2>/dev/null || echo "No XPostgreSQLInstance resources found yet"

echo ""
echo "=== Managed Resources ==="
kubectl get managed 2>/dev/null || echo "No managed resources found yet"

echo ""
echo "=== Aggregated Connection Secret ==="
if kubectl get secret my-db-conn -n default >/dev/null 2>&1; then
	kubectl get secret my-db-conn -n default

	echo ""
	echo "Secret keys:"
	kubectl get secret my-db-conn -n default -o go-template='{{range $k, $v := .data}}{{printf "- %s\n" $k}}{{end}}'

	connection_name=$(kubectl get secret my-db-conn -n default -o jsonpath='{.data.connectionName}' 2>/dev/null)
	if [[ -n "$connection_name" ]]; then
		echo ""
		echo "Decoded connectionName:"
		printf '%s' "$connection_name" | base64 --decode
		echo ""
	fi
else
	echo "No aggregated connection secret found yet"
fi