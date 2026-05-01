# Cloud SQL with Crossplane — Lab

## Goal

Deploy a PostgreSQL instance, database, and user with **Crossplane**.
You can do the lab against real **GCP Cloud SQL** or against **MiniSky** on a local **k3s** cluster.

You will:
- Set up a local Kubernetes cluster with k3s (or k3d)
- Install Crossplane and configure a provider backend
- Design a Crossplane Composition to abstract a Cloud SQL database stack
- Provision the database stack by applying a composite resource through Crossplane
- Make the PostgreSQL major version configurable so it can be upgraded by changing desired state

This branch targets Crossplane XRD `apiextensions.crossplane.io/v2`.
The lab uses a direct `XPostgreSQLInstance` resource as the developer-facing API.

## Supported solution paths

The student can complete this lab in one of two ways:

### Option A — Real GCP

Use a real Google Cloud project and the real GCP Cloud SQL provider.

- This is the closest path to production behavior.
- It requires a Google Cloud account with billing enabled.
- Even if Google offers initial credits or a gift on first signup, billing setup may still require adding a credit card.

### Option B — Local MiniSky

Use [MiniSky](https://github.com/qamarudeenm/minisky), a local GCP emulator, to avoid cloud cost and credit card requirements.

- This path is intended for free local usage.
- It still requires Docker to be installed and running.
- On macOS, use the repo's custom install script instead of relying on the upstream one-step installer.
- For this lab, treat PostgreSQL major-version upgrade verification as a real-GCP-only check. MiniSky is fine for create, list, and delete validation, but it does not reliably emulate instance version upgrades.

## Rules

- You are allowed (and encouraged) to read the official documentation
- Do NOT use AI to generate YAML for you — understand what you write
- Ask questions if you are stuck for more than 30 minutes on the same problem

## Deliverable

A working `kubectl get managed` showing your Cloud SQL resources as `READY=True`,
plus a short explanation in `NOTES.md` of what each component does.

## Repo layout

- Shared Crossplane API: `crossplane/xrd`, `crossplane/composition`, `crossplane/xr`, `crossplane/function`
- Real GCP provider overlay: `crossplane/provider/gcp`
- MiniSky provider overlay: `crossplane/provider/minisky`

## Where to start

Read `docs/01-setup-k3s.md` and follow the steps in order.
When you reach Step 3, choose either the real GCP path or the MiniSky path and keep that choice for the rest of the lab.

## Useful links

- https://docs.crossplane.io
- https://marketplace.upbound.io/providers/upbound/provider-gcp-sql
- https://cloud.google.com/sql/docs
- https://github.com/qamarudeenm/minisky