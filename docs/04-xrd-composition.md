# Step 4 — Write the XRD and the Composition

This is the core of the exercise.

## Concepts to understand first

Before writing anything, make sure you understand:
- What is a **CompositeResourceDefinition (XRD)**?
- What is a **Composition**?
- What is the difference between a *Composite Resource* and a *Claim*?

Read: https://docs.crossplane.io/latest/concepts/compositions/

## What you need to do

Each starter manifest begins with a TODO block at the top. Use it as a checklist for the required items, documentation links, and hints.

### 4.0 — Fill in `crossplane/function/function.yaml`

Install the composition function used by this cluster:
- Use kind `Function`
- Name it `function-patch-and-transform`
- Install the patch-and-transform function package

### 4.1 — Fill in `crossplane/xrd/xrd.yaml`

Define an XRD that:
- Is named `xpostgresqlinstances.db.example.org`
- Exposes a `parameters` object in the spec with at least:
  - `region` (string, required)
  - `tier` (string, optional, with a default value)
  - `databaseVersion` (string, required or defaulted)
  - `databaseName` (string, required or defaulted)
  - `userName` (string, required or defaulted)
  - a way to provide the database user password
- Has claim names so developers can use it from a namespace

### 4.2 — Fill in `crossplane/composition/composition.yaml`

Write a Composition that:
- References your XRD
- Creates a `DatabaseInstance` (GCP Cloud SQL) managed resource
- Creates a `Database` managed resource inside that instance
- Creates a `User` managed resource for that instance
- Uses **patches** to pass instance, database, user, and version settings from the claim to the managed resources
- Makes `databaseVersion` part of the composite API so changing the claim can drive an upgrade
- Disables deletion protection (important for the lab cleanup!)

## What you need to verify before moving on

```bash
kubectl get xrd
# ESTABLISHED=True, OFFERED=True

kubectl get composition
# Should be listed without errors
```

## Hints (read only if stuck)

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