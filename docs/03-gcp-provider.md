# Step 3 — Configure the GCP Provider

Crossplane uses **Providers** to interact with cloud APIs.
You need to install and configure the GCP Cloud SQL provider.

## What you need to do

1. Fill in `crossplane/provider/provider.yaml`
   - Find the correct package name for the GCP Cloud SQL provider on:
     https://marketplace.upbound.io

2. Create a GCP service account with the right permissions
   - Which IAM role does Cloud SQL require?
   - Download a JSON key for that service account

3. Run the helper script to store the credentials as a Kubernetes secret:
   ```bash
   ./scripts/setup-gcp-credentials.sh path/to/your-key.json
   ```

4. Fill in `crossplane/provider/providerconfig.yaml`
   - Set your GCP project ID
   - Reference the secret created in the previous step

## What you need to verify before moving on

```bash
kubectl get provider
# INSTALLED=True, HEALTHY=True

kubectl get providerconfig
# Should show your config without errors
```

## Questions to answer in your NOTES.md

- What is a ProviderConfig in Crossplane?
- Why do we store credentials in a Kubernetes Secret and not directly in the YAML?