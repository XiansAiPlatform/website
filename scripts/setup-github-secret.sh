#!/bin/bash

set -euo pipefail

# Script to help set up GitHub secret for Azure Static Web Apps deployment
# This script retrieves the deployment token and provides instructions for GitHub setup

STATIC_APP_NAME=${UI_APP_NAME:-"xians-public-app"}
WEBAPP_RG=${RESOURCE_GROUP:-"rg-xians-public-app"}
SUBSCRIPTION=${AZ_SUBSCRIPTION:-"XiansAi Prod"}

echo "Setting up GitHub secret for Azure Static Web Apps deployment"
echo "============================================================="
echo ""

# Validate Azure CLI
if ! command -v az >/dev/null 2>&1; then
  echo "Error: Azure CLI is not installed"
  exit 1
fi

if ! az account show >/dev/null 2>&1; then
  echo "Logging in to Azure..."
  az login >/dev/null
fi

if [ -n "$SUBSCRIPTION" ]; then
  echo "Setting subscription to: $SUBSCRIPTION"
  az account set --subscription "$SUBSCRIPTION"
fi

echo "Retrieving deployment token for Static Web App: $STATIC_APP_NAME"
echo ""

DEPLOYMENT_TOKEN=$(az staticwebapp secrets list \
  --name "$STATIC_APP_NAME" \
  --resource-group "$WEBAPP_RG" \
  --query "properties.apiKey" -o tsv 2>/dev/null || echo "")

if [ -z "$DEPLOYMENT_TOKEN" ]; then
  echo "❌ Error: Could not retrieve deployment token"
  echo "Make sure the Static Web App '$STATIC_APP_NAME' exists in resource group '$WEBAPP_RG'"
  exit 1
fi

echo "✅ Successfully retrieved deployment token!"
echo ""
echo "📋 DEPLOYMENT TOKEN (copy this):"
echo "================================"
echo "$DEPLOYMENT_TOKEN"
echo "================================"
echo ""
echo "🔧 GITHUB SETUP INSTRUCTIONS:"
echo "=============================="
echo ""
echo "1. Go to your GitHub repository"
echo "2. Navigate to: Settings → Secrets and variables → Actions"
echo "3. Click 'New repository secret'"
echo "4. Set the following:"
echo "   Name: AZURE_STATIC_WEB_APPS_API_TOKEN"
echo "   Value: $DEPLOYMENT_TOKEN"
echo "5. Click 'Add secret'"
echo ""
echo "🚀 USAGE:"
echo "========="
echo "After setting up the secret, you can deploy by creating and pushing a version tag:"
echo ""
echo "  git tag v1.0.0"
echo "  git push origin v1.0.0"
echo ""
echo "This will trigger the GitHub Action and deploy your site automatically!"
echo ""
echo "💡 TIP: Use semantic versioning for your tags (v1.0.0, v1.1.0, v2.0.0, etc.)"
