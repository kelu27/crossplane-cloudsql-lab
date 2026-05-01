# Step 3 — Choose the provider backend

Crossplane uses **Providers** to interact with cloud APIs.
For this lab, you can either target real GCP or use MiniSky locally.

## Option A — Real GCP

Use this path if you want the student to provision a real Cloud SQL instance in Google Cloud.

Important:

- This path requires a real Google Cloud project.
- In practice, Google Cloud billing usually needs to be enabled on that project.
- Even when Google offers initial signup credits, billing setup may still require adding a credit card.

## What you need to do

1. Fill in `crossplane/provider/provider.yaml`
   - Find the correct package name for the GCP Cloud SQL provider on:
     https://marketplace.upbound.io

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

4. Fill in `crossplane/provider/providerconfig.yaml`
   - Set your GCP project ID
   - Reference the secret created in the previous step

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

5. Continue the exercise using the local MiniSky environment instead of a real Google Cloud project.

## What you need to verify before moving on

```bash
kubectl get provider
# For the real GCP path, the provider should show INSTALLED=True, HEALTHY=True

kubectl get providerconfig
# For the real GCP path, the config should be listed without errors
```

For the MiniSky path, also verify:

```bash
minisky start
# API should be available on localhost and the daemon should remain running
```

## Questions to answer in your NOTES.md

- What is a ProviderConfig in Crossplane?
- Why do we store credentials in a Kubernetes Secret and not directly in the YAML?
- What changes between the real GCP path and the local MiniSky path?