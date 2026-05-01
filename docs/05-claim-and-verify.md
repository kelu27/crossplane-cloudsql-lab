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

Also verify the instance is visible in the GCP Console:
> https://console.cloud.google.com/sql

## Cleanup

When you are done, delete the claim and verify that the Cloud SQL instance
is also deleted from GCP:
```bash
kubectl delete -f crossplane/claim/claim.yaml
```

## Questions to answer in your NOTES.md

- What happens in GCP when you delete a Claim in Kubernetes?
- What is the role of the connection secret?
- How does a version change in the claim propagate to the managed Cloud SQL instance?
- What would you change to make this production-ready?