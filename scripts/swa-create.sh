#!/bin/bash

set -euo pipefail

# Centralized variables with local overrides
STATIC_APP_NAME=${UI_APP_NAME:-"xians-public-app"}
WEBAPP_RG=${RESOURCE_GROUP:-"rg-xians-public-app"}
LOCATION=${LOCATION:-"westeurope"}
TAGS=${TAGS:-"project=xians-public-app environment=prod"}
SKU=${UI_SKU:-"Free"}
SUBSCRIPTION=${AZ_SUBSCRIPTION:-"XiansAi Prod"}
# Vite defaults to dist for output
APP_LOCATION="/public-app"
OUTPUT_LOCATION=${OUTPUT_LOCATION:-"dist"}
API_LOCATION=""

echo "Using configuration:"
echo "  STATIC_APP_NAME=$STATIC_APP_NAME"
echo "  WEBAPP_RG=$WEBAPP_RG"
echo "  LOCATION=$LOCATION"
echo "  SKU=$SKU"
echo "  TAGS=$TAGS"
if [ -n "$SUBSCRIPTION" ]; then
  echo "  SUBSCRIPTION=$SUBSCRIPTION"
fi
echo "  APP_LOCATION=$APP_LOCATION"
echo "  OUTPUT_LOCATION=$OUTPUT_LOCATION"

# Validate Azure CLI is installed
if ! command -v az >/dev/null 2>&1; then
  echo "Error: Azure CLI is not installed. See https://aka.ms/azure-cli"
  exit 1
fi

# Ensure login
if ! az account show >/dev/null 2>&1; then
  echo "Logging in to Azure..."
  az login >/dev/null
fi

# Set subscription if provided
if [ -n "$SUBSCRIPTION" ]; then
  az account set --subscription "$SUBSCRIPTION"
fi

echo "Creating resource group $WEBAPP_RG in $LOCATION..."
az group create \
  --name "$WEBAPP_RG" \
  --location "$LOCATION" \
  --tags $TAGS >/dev/null

echo "Creating Static Web App $STATIC_APP_NAME..."
az staticwebapp create \
  --name "$STATIC_APP_NAME" \
  --resource-group "$WEBAPP_RG" \
  --location "$LOCATION" \
  --tags $TAGS \
  --app-location "$APP_LOCATION" \
  --output-location "$OUTPUT_LOCATION" \
  --api-location "$API_LOCATION" \
  --sku "$SKU" >/dev/null

echo "Retrieving deployment token..."
DEPLOYMENT_TOKEN=$(az staticwebapp secrets list \
  --name "$STATIC_APP_NAME" \
  --resource-group "$WEBAPP_RG" \
  --query "properties.apiKey" -o tsv)

if [ -z "$DEPLOYMENT_TOKEN" ]; then
  echo "Error: Failed to retrieve deployment token"
  exit 1
fi

echo "Deployment token: $DEPLOYMENT_TOKEN"
echo "Export it for CI usage:"
echo "  export AZURE_STATIC_WEB_APPS_API_TOKEN=$DEPLOYMENT_TOKEN"

echo "Done."


