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
- `setup-github-secret.sh`: Retrieves deployment token and shows GitHub secret setup instructions
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

#### 🚀 Automated Deployment (Recommended)

**Deploy via Git Tags:**

Once GitHub Actions is set up, deployment is as simple as:

```bash
git tag v1.0.0
git push origin v1.0.0
```

This will automatically:
- ✅ Build your React application
- ✅ Deploy to Azure Static Web Apps
- ✅ Create a GitHub release
- ✅ Update your live site

**First-time setup:**
1. Run `./setup-github-secret.sh` to get your deployment token
2. Add the token as `AZURE_STATIC_WEB_APPS_API_TOKEN` secret in GitHub
3. Push your first version tag!

#### 🛠️ Manual Deployment

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

### GitHub Actions setup

The repository includes GitHub Actions workflows for automatic deployment on version tags.

#### Quick Setup:

1. **Get deployment token**: `./setup-github-secret.sh`
2. **Add GitHub secret**: 
   - Go to GitHub repo → Settings → Secrets and variables → Actions
   - Add secret named `AZURE_STATIC_WEB_APPS_API_TOKEN` with the token from step 1
3. **Deploy**: Create and push a version tag (e.g., `git tag v1.0.0 && git push origin v1.0.0`)

#### Available Workflows:

- **`deploy-on-tag.yml`** - Uses Azure's official GitHub Action (active, recommended)

#### Tag-Based Deployment Workflow:

1. **Make your changes** and commit them:

   ```bash
   git add .
   git commit -m "Your changes"
   git push
   ```

2. **Create a version tag** (use semantic versioning):

   ```bash
   git tag v1.0.0        # Major release
   git tag v1.1.0        # Minor update
   git tag v1.1.1        # Patch/bugfix
   ```

3. **Push the tag** to trigger deployment:

   ```bash
   git push origin v1.0.0
   ```

4. **Monitor deployment** in GitHub Actions tab - your site will be automatically updated!

#### Tag Naming Conventions:

- **v1.0.0** - Major version (breaking changes)
- **v1.1.0** - Minor version (new features, backward compatible)
- **v1.1.1** - Patch version (bug fixes)
- **v2.0.0-beta.1** - Pre-release versions

#### Manual GitHub Actions setup (alternative):

If you prefer to set up manually:

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


