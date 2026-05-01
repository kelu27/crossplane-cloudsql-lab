# Step 3 — Choose the provider backend

Crossplane uses **Providers** to interact with cloud APIs.
For this lab, you have two valid paths:
- a real GCP project
- a local MiniSky environment

The shared manifests stay the same on both paths:

- `crossplane/xrd/xrd.yaml`
- `crossplane/composition/composition.yaml`
- `crossplane/xr/xr.yaml`
- `crossplane/function/function.yaml`

Only the provider overlay changes:

- Real GCP: `crossplane/provider/gcp`
- MiniSky: `crossplane/provider/minisky`

## Option A — Real GCP

Use this path if you want to provision a real Cloud SQL instance in Google Cloud.

- This path requires a real Google Cloud project.
- Billing usually needs to be enabled on that project.

## What you need to do

1. Apply the real GCP provider overlay from `crossplane/provider/gcp`
   - `provider.yaml` installs the provider package
   - `providerconfig.yaml` points that provider at your real GCP project

2. Create a GCP service account before you create the credentials secret
   - Pick a project ID and export it so you can reuse it:
     ```bash
     export PROJECT_ID="your-gcp-project-id"
     ```
   - Create a service account for Crossplane:
     ```bash
     gcloud iam service-accounts create crossplane-cloudsql \
       --project "$PROJECT_ID" \
       --display-name "Crossplane Cloud SQL"
     ```
   - Grant that service account the permissions it needs. A common starting point is `roles/cloudsql.admin`:
     ```bash
     gcloud projects add-iam-policy-binding "$PROJECT_ID" \
       --member "serviceAccount:crossplane-cloudsql@$PROJECT_ID.iam.gserviceaccount.com" \
       --role "roles/cloudsql.admin"
     ```
   - Create and download a JSON key for that service account:
     ```bash
     gcloud iam service-accounts keys create ./crossplane-cloudsql-key.json \
       --iam-account "crossplane-cloudsql@$PROJECT_ID.iam.gserviceaccount.com"
     ```

3. Run the helper script to store the credentials as a Kubernetes secret:
   ```bash
   ./scripts/gcp/setup-gcp-credentials.sh ./crossplane-cloudsql-key.json
   ```

4. Update `crossplane/provider/gcp/providerconfig.yaml`
  - Set your GCP project ID
  - Keep the secret reference created in the previous step

5. Apply the real GCP provider manifests:
  ```bash
  kubectl apply -f crossplane/provider/gcp/provider.yaml
  kubectl wait --for=condition=Healthy provider.pkg.crossplane.io/provider-gcp-sql --timeout=300s
  kubectl apply -f crossplane/provider/gcp/providerconfig.yaml
  ```

## Option B — Local MiniSky

Use this path if you want to work locally without a credit card.

MiniSky is a local GCP emulator.

1. Install Docker Desktop and make sure Docker is running.

2. Install MiniSky.

   On Linux, or on macOS where the upstream installer works, you can use the normal installer:
   ```bash
   curl -sSL https://minisky.bmics.com.ng/install.sh | sh
   ```

   On macOS, use the repository's custom installer instead:
   ```bash
   ./scripts/minisky/minisky.sh
   ```

3. If MiniSky fails on macOS with a Docker socket error such as:
   ```text
   [FATAL] Cannot create isolated minisky-net network: Get "http://localhost/networks/minisky-net": dial unix /var/run/docker.sock: connect: no such file or directory
   ```
   then build it manually from source:
   ```bash
   git clone https://github.com/qamarudeenm/minisky.git
   cd minisky/ui
   npm ci
   npm run build
   cd ..
   go build -o /usr/local/bin/minisky ./cmd/minisky
   minisky start
   ```

4. Start MiniSky:
   ```bash
   minisky start
   ```

5. Understand the MiniSky-specific pieces:
  - `providerconfig.yaml` uses `credentials.source: AccessToken`
  - `provider.yaml` adds a MiniSky-only `runtimeConfigRef`
  - `minisky-sql-proxy.yaml` deploys an in-cluster proxy for Cloud SQL traffic
  - the provider uses `GOOGLE_SQL_CUSTOM_ENDPOINT=http://minisky-sql-proxy.crossplane-system.svc.cluster.local:8080/`
  - the proxy is required because MiniSky routes Cloud SQL traffic by the `Host` header `sqladmin.googleapis.com`

6. Create a local emulator access token secret for the provider:
  ```bash
  ./scripts/minisky/setup-minisky-credentials.sh
  ```

7. Apply the MiniSky-oriented provider manifests:
  ```bash
  kubectl apply -f crossplane/provider/minisky/minisky-sql-proxy.yaml
  kubectl apply -f crossplane/provider/minisky/runtimeconfig.yaml
  kubectl apply -f crossplane/provider/minisky/provider.yaml
  kubectl wait --for=condition=Healthy provider.pkg.crossplane.io/provider-gcp-sql --timeout=300s
  kubectl apply -f crossplane/provider/minisky/providerconfig.yaml
  ```

8. Continue the lab using the local MiniSky environment instead of a real Google Cloud project.

Important limitation:

- MiniSky is good enough to validate Cloud SQL instance creation, observation, database creation, user creation, and deletion.
- MiniSky does not currently behave like real GCP for PostgreSQL major-version upgrades on an existing Cloud SQL instance.
- If you change `databaseVersion` in the composite resource on the MiniSky path, Crossplane will propagate the desired value, but the emulator may reject the provider's update call.
- Treat version-upgrade verification as a real-GCP-only check unless you extend the MiniSky Cloud SQL shim.

## What you need to verify before moving on

```bash
kubectl get provider
# For either path, the provider should show INSTALLED=True, HEALTHY=True

kubectl get providerconfig
# The selected backend config should be listed without errors
```

If `ProviderConfig` fails on a fresh cluster with `no matches for kind "ProviderConfig"`, the provider CRDs are not installed yet. Wait for `provider-gcp-sql` to become `HEALTHY=True`, then apply `ProviderConfig` again.

For the MiniSky path, also verify:

```bash
minisky start
# The daemon should stay running

kubectl get deploymentruntimeconfig provider-gcp-sql-minisky
kubectl get deploy,svc -n crossplane-system minisky-sql-proxy
kubectl describe providerconfig default
# ProviderConfig should use AccessToken and reference crossplane-system/gcp-credentials
```

## Questions to answer in your NOTES.md

- What is a ProviderConfig in Crossplane?
- Why do we store credentials in a Kubernetes Secret and not directly in the YAML?