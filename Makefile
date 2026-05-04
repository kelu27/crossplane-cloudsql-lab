.PHONY: check apply-function apply-provider-gcp apply-provider-minisky apply-xrd apply-composition apply-xr clean

check:
	@./scripts/check.sh

apply-function:
	kubectl apply -f crossplane/function/function.yaml
	kubectl wait --for=condition=Healthy function.pkg.crossplane.io/function-patch-and-transform --timeout=300s

apply-provider-gcp:
	kubectl apply -f crossplane/provider/gcp/provider.yaml
	kubectl wait --for=condition=Healthy provider.pkg.crossplane.io/provider-gcp-sql --timeout=300s
	kubectl apply -f crossplane/provider/gcp/providerconfig.yaml

apply-provider-minisky:
	kubectl apply -f crossplane/provider/minisky/minisky-sql-proxy.yaml
	kubectl apply -f crossplane/provider/minisky/runtimeconfig.yaml
	kubectl apply -f crossplane/provider/minisky/provider.yaml
	kubectl wait --for=condition=Healthy provider.pkg.crossplane.io/provider-gcp-sql --timeout=300s
	kubectl apply -f crossplane/provider/minisky/providerconfig.yaml

apply-xrd:
	kubectl apply -f crossplane/xrd/xrd.yaml

apply-composition:
	kubectl apply -f crossplane/composition/composition.yaml

apply-xr:
	kubectl apply -f crossplane/xr/xr.yaml

clean:
	kubectl delete -f crossplane/xr/xr.yaml --ignore-not-found
