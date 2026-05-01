Makefile
.PHONY: check apply-provider apply-xrd apply-composition apply-xr clean

check:
	@./scripts/check.sh

apply-provider:
	kubectl apply -f crossplane/provider/provider.yaml
	kubectl apply -f crossplane/provider/providerconfig.yaml

apply-xrd:
	kubectl apply -f crossplane/xrd/xrd.yaml

apply-composition:
	kubectl apply -f crossplane/composition/composition.yaml

apply-xr:
	kubectl apply -f crossplane/xr/xr.yaml

clean:
	kubectl delete -f crossplane/xr/xr.yaml --ignore-not-found