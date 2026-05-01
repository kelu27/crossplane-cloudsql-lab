# Step 5 — Create a Claim and verify

## What you need to do

Fill in `crossplane/claim/claim.yaml` to create a PostgreSQL database stack:
- Use the `PostgreSQLInstance` kind (the claim kind from your XRD)
- Set `region` to `europe-west1`
- Set a database name
- Set a user name
- Provide a password for that user
- Set an initial PostgreSQL version
- Ask Crossplane to write the connection details to a secret called `my-db-conn`

Apply it:
```bash
kubectl apply -f crossplane/claim/claim.yaml
```

## What you need to verify

```bash
# Watch the managed resources being provisioned
kubectl get managed

# Check the claim status
kubectl get postgresqlinstance

# Once ready, inspect the connection secret
kubectl get secret my-db-conn -o yaml

# After the initial provisioning works, verify that changing the desired
# PostgreSQL version updates the managed Cloud SQL instance.
```

Backend-specific note for the version-upgrade check:

- On the real GCP path, changing `spec.parameters.databaseVersion` is part of the exercise and should be verified.
- On the MiniSky path, changing `spec.parameters.databaseVersion` is not a reliable upgrade test.
- The emulator currently supports the create/list/delete path well enough for this lab, but it does not reliably implement Cloud SQL instance version updates.
- On MiniSky, you should still verify that the new desired version appears in the claim and composed resource spec, even if the emulator does not apply the upgrade.

If you are using the real GCP path, also verify the instance is visible in the GCP Console:
> https://console.cloud.google.com/sql

## Cleanup

When you are done, delete the claim and verify that the composed resources are cleaned up.

On the real GCP path, this means verifying that the Cloud SQL instance is also deleted from GCP.

On the MiniSky path, this means verifying that the claim, composite, and composed managed resources disappear from the cluster and emulator-backed state:
```bash
kubectl delete -f crossplane/claim/claim.yaml
```

## Questions to answer in your NOTES.md

- What happens in GCP when you delete a Claim in Kubernetes?
- What is the role of the connection secret?
- How does a version change in the claim propagate to the managed Cloud SQL instance?
- Why is the version-upgrade check different on the MiniSky path?
- If you are using MiniSky, prove that the upgrade limitation is caused by the emulator and not by your Crossplane manifests. What evidence shows that your changed `databaseVersion` reached the claim and composed managed resource correctly?
- What would you change to make this production-ready?