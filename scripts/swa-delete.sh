#!/bin/bash

set -euo pipefail

STATIC_APP_NAME=${UI_APP_NAME:-"xians-public-app"}
WEBAPP_RG=${RESOURCE_GROUP:-"rg-xians-public-app"}
SUBSCRIPTION=${AZ_SUBSCRIPTION:-""}

if ! command -v az >/dev/null 2>&1; then
  echo "Error: Azure CLI is not installed. See https://aka.ms/azure-cli"
  exit 1
fi

if ! az account show >/dev/null 2>&1; then
  echo "Logging in to Azure..."
  az login >/dev/null
fi

if [ -n "$SUBSCRIPTION" ]; then
  az account set --subscription "$SUBSCRIPTION"
fi

echo "Deleting Static Web App $STATIC_APP_NAME in $WEBAPP_RG..."
az staticwebapp delete \
  --name "$STATIC_APP_NAME" \
  --resource-group "$WEBAPP_RG" \
  --yes >/dev/null || true

echo "Optionally delete resource group $WEBAPP_RG (y/N)?"
read -r REPLY
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
  az group delete --name "$WEBAPP_RG" --yes --no-wait
  echo "Resource group deletion started."
fi

echo "Done."


