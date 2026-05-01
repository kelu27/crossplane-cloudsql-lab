# Step 5 — Create the Composite Resource and verify

## What you need to do

Fill in `crossplane/xr/xr.yaml` to create a PostgreSQL database stack.

- Use the `XPostgreSQLInstance` kind from your XRD
- Do not set a namespace on the `XPostgreSQLInstance` itself
- Set `region` to `europe-west1`
- Set a database name
- Set a user name
- Provide a password for that user
- Reference the namespace that stores the password Secret
- Ask Crossplane to write aggregated connection details to a Secret named `my-db-conn`
  in namespace `default`
- Set an initial PostgreSQL version

This file should be the only manifest a developer needs to request the full database stack.

Apply it:
```bash
kubectl apply -f crossplane/xr/xr.yaml
```

## What you need to verify

```bash
# Watch the managed resources being provisioned
kubectl get managed

# Check the composite resource status
kubectl get xpostgresqlinstances

# Inspect the aggregated connection details secret
kubectl get secret my-db-conn -n default -o yaml

# After the initial provisioning works, verify that changing the desired
# PostgreSQL version updates the managed Cloud SQL instance.
```

You do not need every field in the secret for this lab. The most useful first check is that the secret exists and that `connectionName` matches the created Cloud SQL instance.

Backend-specific note for the version-upgrade check:

- On the real GCP path, changing `spec.parameters.databaseVersion` is part of the exercise and should be verified.
- On the MiniSky path, changing `spec.parameters.databaseVersion` is not a reliable upgrade test.
- The emulator currently supports the create/list/delete path well enough for this lab, but it does not reliably implement Cloud SQL instance version updates.
- On MiniSky, you should still verify that the new desired version appears in the composite resource and composed managed resource spec, even if the emulator does not apply the upgrade.

If you are using the real GCP path, also verify that the instance is visible in the GCP Console:
> https://console.cloud.google.com/sql

## Cleanup

When you are done, delete the composite resource and verify that the composed resources are cleaned up.

On the real GCP path, this means verifying that the Cloud SQL instance is also deleted from GCP.

On the MiniSky path, this means verifying that the composite resource, the connection Secret, and the composed managed resources disappear from the cluster and emulator-backed state:
```bash
kubectl delete -f crossplane/xr/xr.yaml
```

## Questions to answer in your NOTES.md

- What happens in GCP when you delete the composite resource in Kubernetes?
- What information is stored in the aggregated connection Secret, and who should consume it?
- How does a version change in the composite resource propagate to the managed Cloud SQL instance?
- Why is the version-upgrade check different on the MiniSky path?
- If you are using MiniSky, prove that the upgrade limitation is caused by the emulator and not by your Crossplane manifests. What evidence shows that your changed `databaseVersion` reached the composite resource and composed managed resource correctly?
- What would you change to make this production-ready?