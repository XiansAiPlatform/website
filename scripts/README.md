## Azure Static Web Apps scripts

These scripts provision and manage an Azure Static Web App for the Vite React app in this folder, with special focus on the Xians.ai production deployment and DNS migration.

### Prerequisites

- Azure CLI installed and logged in (`az login`).
- Access to "XiansAi Prod" Azure subscription.
- Node.js and npm installed for building the application.

### Files

- `deploy-xians.sh`: **Main deployment script** - orchestrates the complete deployment process
- `swa-create.sh`: Creates the resource group and Static Web App, then prints the deployment token
- `swa-deploy.sh`: Deploys built application files to the Static Web App using SWA CLI
- `swa-delete.sh`: Deletes the Static Web App and optionally the resource group
- `swa-domain.sh`: Manages custom domain configuration (add/remove/validate)
- `swa-migrate.sh`: Finds existing deployments and handles domain migration
- Root-level `staticwebapp.config.json`: SPA fallback and headers

### Defaults and overrides

Environment variables you can override when running scripts:

- `UI_APP_NAME` (default: `xians-public-app`)
- `RESOURCE_GROUP` (default: `rg-xians-public-app`)
- `LOCATION` (default: `westeurope`)
- `UI_SKU` (default: `Free`)
- `AZ_SUBSCRIPTION` (default: `XiansAi Prod`)
- `OUTPUT_LOCATION` (default: `dist` — Vite build output)
- `CUSTOM_DOMAIN` (default: `xians.ai`)

### Usage

**Quick Start - Complete Deployment:**

```bash
cd scripts
./deploy-xians.sh full
```

This will:
1. Build the application
2. Create the Static Web App
3. Handle domain migration from existing deployments
4. Configure the custom domain

**Individual Operations:**

```bash
# Check current status
./deploy-xians.sh status

# Build application only
./deploy-xians.sh build

# Create Static Web App only
./deploy-xians.sh create

# Deploy application files only
./deploy-xians.sh deploy

# Handle domain migration
./deploy-xians.sh migrate

# Configure custom domain
./deploy-xians.sh domain

# Clean up old deployments
./deploy-xians.sh cleanup
```

**Manual Static Web App Creation (legacy):**

```bash
cd ../
npm ci
npm run build
cd scripts
./swa-create.sh
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

### Domain Management

**Check existing domain usage:**
```bash
./swa-migrate.sh check
```

**Find all Static Web Apps:**
```bash
./swa-migrate.sh find
```

**Manage custom domain:**
```bash
# Validate domain configuration
./swa-domain.sh validate

# Add custom domain
./swa-domain.sh add

# Remove custom domain
./swa-domain.sh remove

# List all domains
./swa-domain.sh list
```

### Delete

```bash
# Using default names
./swa-delete.sh

# Using custom names
UI_APP_NAME=xians-public-app-uat RESOURCE_GROUP=rg-xians-public-app-uat ./swa-delete.sh
```

### DNS Migration Process

When migrating from an existing deployment:

1. **Check current setup:** `./deploy-xians.sh status`
2. **Find existing apps:** `./swa-migrate.sh find`
3. **Check domain usage:** `./swa-migrate.sh check`
4. **Run full deployment:** `./deploy-xians.sh full`

The deployment script will automatically handle domain migration by:
- Identifying apps using the xians.ai domain
- Prompting to remove the domain from old apps
- Adding the domain to the new deployment


