# Step 2 — Install Crossplane

Crossplane is installed via Helm.

## What you need to do

- Add the Crossplane Helm repository
- Install Crossplane in a dedicated namespace called `crossplane-system`
```bash
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update
 helm install crossplane \
--namespace crossplane-system \
--create-namespace crossplane-stable/crossplane
```
- Verify all pods are running

## What you need to verify before moving on

```bash
kubectl get pods -n crossplane-system
kubectl get crds | grep crossplane
```

## Questions to answer in your NOTES.md

- What is Crossplane? What problem does it solve?
- What are the core CRDs introduced by Crossplane?
