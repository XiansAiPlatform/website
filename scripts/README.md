## Azure Static Web Apps scripts

These scripts provision and manage an Azure Static Web App for the Vite React app in this folder.

### Prerequisites

- Azure CLI installed and logged in (`az login`).
- Appropriate Azure subscription access.

### Files

- `swa-create.sh`: Creates the resource group and Static Web App, then prints the deployment token.
- `swa-delete.sh`: Deletes the Static Web App and optionally the resource group.
- Root-level `staticwebapp.config.json`: SPA fallback and headers.

### Defaults and overrides

Environment variables you can override when running scripts:

- `UI_APP_NAME` (default: `xians-public-app`)
- `RESOURCE_GROUP` (default: `rg-xians-public-app`)
- `LOCATION` (default: `westeurope`)
- `UI_SKU` (default: `Free`)
- `AZ_SUBSCRIPTION` (optional: subscription id or name)
- `OUTPUT_LOCATION` (default: `dist` — Vite build output)

### Usage

Build the app and create the Static Web App:

```bash
cd ../
npm ci
npm run build
cd scripts
UI_APP_NAME=xians-public-app-uat RESOURCE_GROUP=rg-xians-public-app-uat LOCATION=westeurope ./swa-create.sh
```

The script outputs `AZURE_STATIC_WEB_APPS_API_TOKEN`. Save it for CI/CD.

### GitHub Actions setup (optional)

1. In GitHub repo, go to Settings → Secrets and variables → Actions.
2. Add a new secret named `AZURE_STATIC_WEB_APPS_API_TOKEN` with the token from `swa-create.sh`.
3. Use an action like:

```yaml
name: Deploy Public App
on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
        working-directory: platform/website/public-app
      - run: npm run build
        working-directory: platform/website/public-app
      - name: Deploy to Azure Static Web Apps
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: upload
          app_location: "/"
          output_location: "dist"
```

### Delete

```bash
UI_APP_NAME=xians-public-app-uat RESOURCE_GROUP=rg-xians-public-app-uat ./swa-delete.sh
```


