# Step 3 — Choose the provider backend

Crossplane uses **Providers** to interact with cloud APIs.
For this lab, you can either target real GCP or use MiniSky locally.

Shared manifests stay the same for both paths:

- `crossplane/xrd/xrd.yaml`
- `crossplane/composition/composition.yaml`
- `crossplane/claim/claim.yaml`
- `crossplane/function/function.yaml`

Each starter manifest in this repo begins with a TODO block that lists the required fields, references, and hints for the student.

Only the provider overlay changes:

- Real GCP: `crossplane/provider/gcp`
- MiniSky: `crossplane/provider/minisky`

## Option A — Real GCP

Use this path if you want the student to provision a real Cloud SQL instance in Google Cloud.

Important:

- This path requires a real Google Cloud project.
- In practice, Google Cloud billing usually needs to be enabled on that project.
- Even when Google offers initial signup credits, billing setup may still require adding a credit card.

## What you need to do

1. Apply the real GCP provider overlay from `crossplane/provider/gcp`
  - `provider.yaml` installs the provider package
  - `providerconfig.yaml` points that provider at your real GCP project

2. Create a GCP service account before you create the credentials secret
   - Pick a project ID and export it so you can reuse it in commands:
     ```bash
     export PROJECT_ID="your-gcp-project-id"
     ```
   - Create a service account for Crossplane:
     ```bash
     gcloud iam service-accounts create crossplane-cloudsql \
       --project "$PROJECT_ID" \
       --display-name "Crossplane Cloud SQL"
     ```
   - Grant that service account the permissions it needs for this lab.
     For this exercise, start by checking which role is required to manage Cloud SQL.
     A common starting point is `roles/cloudsql.admin`:
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

Use this path if you want the student to work locally without a credit card.

MiniSky is a local GCP emulator that can be used for free on a laptop.

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

5. For the MiniSky path, the Crossplane provider must be configured differently from real GCP:
  - `crossplane/provider/minisky/providerconfig.yaml` should keep `projectID: local-dev-project`
  - `crossplane/provider/minisky/providerconfig.yaml` should use `credentials.source: AccessToken`
  - `crossplane/provider/minisky/providerconfig.yaml` should reference a Kubernetes secret named `gcp-credentials`
  - apply `crossplane/provider/minisky/provider.yaml`, which adds the MiniSky-only `runtimeConfigRef`
  - deploy the in-cluster Cloud SQL proxy in `crossplane/provider/minisky/minisky-sql-proxy.yaml`
  - the SQL provider deployment must be started with:
    - `GOOGLE_SQL_CUSTOM_ENDPOINT=http://minisky-sql-proxy.crossplane-system.svc.cluster.local:8080/`
  - the proxy is needed because MiniSky dispatches Cloud SQL by the upstream `Host` header (`sqladmin.googleapis.com`), while direct calls from the cluster arrive with a different host and return `501`

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

8. Continue the exercise using the local MiniSky environment instead of a real Google Cloud project.

Important limitation for this lab:

- MiniSky is good enough to validate Cloud SQL instance creation, observation, database creation, user creation, and deletion.
- MiniSky does not currently behave like real GCP for PostgreSQL major-version upgrades on an existing Cloud SQL instance.
- If you change `databaseVersion` in the claim on the MiniSky path, Crossplane will propagate the desired value, but the emulator may reject the provider's update call.
- Treat version-upgrade verification as a real-GCP-only check unless you extend the MiniSky Cloud SQL shim.

## What you need to verify before moving on

```bash
kubectl get provider
# For either path, the provider should show INSTALLED=True, HEALTHY=True

kubectl get providerconfig
# The selected backend config should be listed without errors
```

If `ProviderConfig` fails on a fresh cluster with `no matches for kind "ProviderConfig"`, the provider CRDs are not installed yet. Wait for `provider-gcp-sql` to become `HEALTHY=True`, then apply the `ProviderConfig` again.

For the MiniSky path, also verify:

```bash
minisky start
# API should be available on localhost and the daemon should remain running

kubectl get deploymentruntimeconfig provider-gcp-sql-minisky
kubectl get deploy,svc -n crossplane-system minisky-sql-proxy
kubectl describe providerconfig default
# ProviderConfig should use AccessToken and reference crossplane-system/gcp-credentials on the MiniSky path
```

## Questions to answer in your NOTES.md

- What is a ProviderConfig in Crossplane?
- Why do we store credentials in a Kubernetes Secret and not directly in the YAML?