#!/bin/bash

set -euo pipefail

# Script to deploy built application to Azure Static Web App using SWA CLI
# This script handles the actual deployment of files to the Static Web App

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PUBLIC_APP_DIR="$PROJECT_DIR/public-app"

STATIC_APP_NAME=${UI_APP_NAME:-"xians-public-app"}
WEBAPP_RG=${RESOURCE_GROUP:-"rg-xians-public-app"}
SUBSCRIPTION=${AZ_SUBSCRIPTION:-"XiansAi Prod"}
DEPLOYMENT_TOKEN=${AZURE_STATIC_WEB_APPS_API_TOKEN:-""}

usage() {
  echo "Usage: $0 [deployment-token]"
  echo ""
  echo "Deploy built application to Azure Static Web App"
  echo ""
  echo "Options:"
  echo "  deployment-token    Optional deployment token (can also use AZURE_STATIC_WEB_APPS_API_TOKEN env var)"
  echo ""
  echo "Environment variables:"
  echo "  UI_APP_NAME (default: xians-public-app)"
  echo "  RESOURCE_GROUP (default: rg-xians-public-app)"
  echo "  AZ_SUBSCRIPTION (default: XiansAi Prod)"
  echo "  AZURE_STATIC_WEB_APPS_API_TOKEN (deployment token)"
}

validate_prerequisites() {
  # Check if SWA CLI is installed
  if ! command -v swa >/dev/null 2>&1; then
    echo "Azure Static Web Apps CLI not found. Installing..."
    npm install -g @azure/static-web-apps-cli
  fi

  # Check if build exists
  if [ ! -d "$PUBLIC_APP_DIR/dist" ]; then
    echo "Error: Build directory not found at $PUBLIC_APP_DIR/dist"
    echo "Please run the build first: npm run build"
    exit 1
  fi

  # Check if index.html exists
  if [ ! -f "$PUBLIC_APP_DIR/dist/index.html" ]; then
    echo "Error: index.html not found in build directory"
    exit 1
  fi
}

get_deployment_token() {
  if [ -n "${1:-}" ]; then
    DEPLOYMENT_TOKEN="$1"
  elif [ -z "$DEPLOYMENT_TOKEN" ]; then
    echo "Getting deployment token from Azure..."
    
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
      az account set --subscription "$SUBSCRIPTION"
    fi

    DEPLOYMENT_TOKEN=$(az staticwebapp secrets list \
      --name "$STATIC_APP_NAME" \
      --resource-group "$WEBAPP_RG" \
      --query "properties.apiKey" -o tsv 2>/dev/null || echo "")

    if [ -z "$DEPLOYMENT_TOKEN" ]; then
      echo "Error: Could not retrieve deployment token"
      echo "Make sure the Static Web App '$STATIC_APP_NAME' exists in resource group '$WEBAPP_RG'"
      exit 1
    fi
  fi
}

deploy_application() {
  echo "Deploying application to Azure Static Web App..."
  echo "  App: $STATIC_APP_NAME"
  echo "  Source: $PUBLIC_APP_DIR/dist"
  echo ""

  cd "$PUBLIC_APP_DIR"

  # Deploy to production environment
  swa deploy ./dist \
    --deployment-token "$DEPLOYMENT_TOKEN" \
    --env production

  echo ""
  echo "Deployment completed successfully!"
  
  # Get the app URL
  if command -v az >/dev/null 2>&1 && az account show >/dev/null 2>&1; then
    APP_URL=$(az staticwebapp show \
      --name "$STATIC_APP_NAME" \
      --resource-group "$WEBAPP_RG" \
      --query "defaultHostname" -o tsv 2>/dev/null || echo "")
    
    if [ -n "$APP_URL" ]; then
      echo "Your application is now live at: https://$APP_URL"
    fi
  fi
}

main() {
  if [ "${1:-}" = "help" ] || [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    usage
    exit 0
  fi

  validate_prerequisites
  get_deployment_token "${1:-}"
  deploy_application
}

main "$@"
