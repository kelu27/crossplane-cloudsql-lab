# Cloud SQL on GCP with Crossplane — Lab

## Goal

Deploy a **Cloud SQL (PostgreSQL)** instance, database, and user on GCP using
**Crossplane**, running on a local **k3s** cluster on your laptop.

You will:
- Set up a local Kubernetes cluster with k3s (or k3d)
- Install Crossplane and configure a GCP provider
- Design a Crossplane Composition to abstract a Cloud SQL database stack
- Provision the database stack by applying a simple Kubernetes Claim
- Make the PostgreSQL major version configurable so it can be upgraded by changing desired state

## Rules

- You are allowed (and encouraged) to read the official documentation
- Do NOT use AI to generate YAML for you — understand what you write
- Ask questions if you are stuck for more than 30 minutes on the same problem

## Deliverable

A working `kubectl get managed` showing your Cloud SQL resources as `READY=True`,
and a short explanation (written in `NOTES.md`) of what each component does.

## Where to start

Read `docs/01-setup-k3s.md` and follow the steps in order.

## Useful links

- https://docs.crossplane.io
- https://marketplace.upbound.io/providers/upbound/provider-gcp-cloudsql
- https://cloud.google.com/sql/docs