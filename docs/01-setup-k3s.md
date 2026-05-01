# Step 1 — Set up a local Kubernetes cluster

You need a local Kubernetes cluster running on your laptop.

## Option A — k3s (native)

Install k3s directly on your machine:
> https://k3s.io

## Option B — k3d (recommended if you use Docker)

k3d runs k3s inside Docker containers, which is easier to reset and manage.
> https://k3d.sigs.k8s.io

## What you need to verify before moving on

```bash
kubectl get nodes
# You should see at least one node with STATUS=Ready
```

## Questions to answer in your NOTES.md

- What is the difference between k3s and k8s?
- What is k3d and why is it useful on a laptop?