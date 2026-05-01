# Step 4 — Write the XRD and the Composition

This is the core of the lab.

## Concepts to understand first

Before you write anything, make sure you understand:
- What is a **CompositeResourceDefinition (XRD)**?
- What is a **Composition**?
- How does a *Composite Resource* become the API that developers apply?

Read: https://docs.crossplane.io/latest/concepts/compositions/

## What you need to do

Each starter manifest begins with a TODO block. Use it as your checklist.

### 4.0 — Fill in `crossplane/function/function.yaml`

Install the composition function used by this cluster:
- Use kind `Function`
- Name it `function-patch-and-transform`
- Install the patch-and-transform function package
- Use a release that supports v2 XR connection secrets, for example `v0.10.4`

### 4.1 — Fill in `crossplane/xrd/xrd.yaml`

Define an XRD that:
- Is named `xpostgresqlinstances.db.example.org`
- Uses `apiVersion: apiextensions.crossplane.io/v2`
- Uses `spec.scope: Cluster`
- Exposes a `parameters` object in the spec with at least:
  - `region` (string, required)
  - `tier` (string, optional, with a default value)
  - `databaseVersion` (string, required or defaulted)
  - `databaseName` (string, required or defaulted)
  - `userName` (string, required or defaulted)
  - a way to provide the database user password, including which namespace stores the Secret
- Produces an `XPostgreSQLInstance` resource that developers can apply directly

Keep the API simple. The goal is to let a developer request one PostgreSQL stack without needing to know the Cloud SQL managed resource details.

### 4.2 — Fill in `crossplane/composition/composition.yaml`

Write a Composition that:
- References your XRD
- Creates a `DatabaseInstance` (GCP Cloud SQL) managed resource
- Creates a `Database` managed resource inside that instance
- Creates a `User` managed resource for that instance
- Uses **patches** to pass instance, database, user, and version settings from the composite resource to the managed resources
- Makes `databaseVersion` part of the composite API so changing the composite resource can drive an upgrade
- Disables deletion protection (important for the lab cleanup!)

At the end of this step, a developer should only need one XR manifest to ask for the whole database stack.

## What you need to verify before moving on

```bash
kubectl get xrd
# ESTABLISHED=True, OFFERED=True

kubectl get composition
# Should be listed without errors
```

## Hints (read only if you are stuck)

<details>
  <summary>Hint 1 — XRD structure</summary>
  The XRD defines an OpenAPI schema. Look at how `spec.versions[].schema.openAPIV3Schema`
  is structured. Your `parameters` object lives under `spec`.
</details>

<details>
  <summary>Hint 2 — Composition patches</summary>
  Use `FromCompositeFieldPath` patch type to map fields from the composite resource
  to the managed resource. The `fromFieldPath` points to the composite,
  the `toFieldPath` points to the managed resource spec.
</details>