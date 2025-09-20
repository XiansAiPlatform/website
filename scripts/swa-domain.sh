#!/bin/bash

set -euo pipefail

# Script to manage custom domain configuration for Azure Static Web Apps
# This script handles adding/removing custom domains and manages DNS migration

STATIC_APP_NAME=${UI_APP_NAME:-"xians-public-app"}
WEBAPP_RG=${RESOURCE_GROUP:-"rg-xians-public-app"}
SUBSCRIPTION=${AZ_SUBSCRIPTION:-"XiansAi Prod"}
CUSTOM_DOMAIN=${CUSTOM_DOMAIN:-"xians.ai"}

ACTION=${1:-"help"}

usage() {
  echo "Usage: $0 <action>"
  echo "Actions:"
  echo "  add       - Add custom domain to the static web app"
  echo "  remove    - Remove custom domain from the static web app"
  echo "  list      - List all domains for the static web app"
  echo "  validate  - Validate custom domain configuration"
  echo "  help      - Show this help message"
  echo ""
  echo "Environment variables:"
  echo "  UI_APP_NAME (default: xians-public-app)"
  echo "  RESOURCE_GROUP (default: rg-xians-public-app)"
  echo "  AZ_SUBSCRIPTION (default: XiansAi Prod)"
  echo "  CUSTOM_DOMAIN (default: xians.ai)"
}

validate_azure_cli() {
  if ! command -v az >/dev/null 2>&1; then
    echo "Error: Azure CLI is not installed. See https://aka.ms/azure-cli"
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
}

get_static_app_hostname() {
  az staticwebapp show \
    --name "$STATIC_APP_NAME" \
    --resource-group "$WEBAPP_RG" \
    --query "defaultHostname" -o tsv 2>/dev/null || echo ""
}

list_domains() {
  echo "Listing domains for $STATIC_APP_NAME..."
  
  # Get the default hostname
  DEFAULT_HOSTNAME=$(get_static_app_hostname)
  if [ -n "$DEFAULT_HOSTNAME" ]; then
    echo "Default hostname: $DEFAULT_HOSTNAME"
  fi
  
  # List custom domains
  echo "Custom domains:"
  az staticwebapp hostname list \
    --name "$STATIC_APP_NAME" \
    --resource-group "$WEBAPP_RG" \
    --query "[].name" -o tsv 2>/dev/null || echo "No custom domains found"
}

validate_domain() {
  echo "Validating domain configuration for $CUSTOM_DOMAIN..."
  
  # Check if static web app exists
  if ! az staticwebapp show --name "$STATIC_APP_NAME" --resource-group "$WEBAPP_RG" >/dev/null 2>&1; then
    echo "Error: Static Web App '$STATIC_APP_NAME' not found in resource group '$WEBAPP_RG'"
    exit 1
  fi
  
  # Get the default hostname for CNAME validation
  DEFAULT_HOSTNAME=$(get_static_app_hostname)
  if [ -z "$DEFAULT_HOSTNAME" ]; then
    echo "Error: Could not retrieve default hostname"
    exit 1
  fi
  
  echo "Default hostname: $DEFAULT_HOSTNAME"
  echo "Custom domain: $CUSTOM_DOMAIN"
  echo ""
  echo "DNS Configuration Required:"
  echo "  Create a CNAME record for '$CUSTOM_DOMAIN' pointing to '$DEFAULT_HOSTNAME'"
  echo "  Or create an ALIAS record if using apex domain"
  
  # Check current DNS resolution
  echo ""
  echo "Current DNS resolution for $CUSTOM_DOMAIN:"
  nslookup "$CUSTOM_DOMAIN" || dig "$CUSTOM_DOMAIN" || echo "DNS lookup failed"
}

add_domain() {
  echo "Adding custom domain $CUSTOM_DOMAIN to $STATIC_APP_NAME..."
  
  validate_azure_cli
  
  # Validate domain first
  validate_domain
  
  echo ""
  read -p "Have you configured the DNS CNAME record? (y/N): " -r
  if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    echo "Please configure the DNS record first and try again."
    exit 1
  fi
  
  # Add the custom domain
  echo "Adding custom domain..."
  az staticwebapp hostname set \
    --name "$STATIC_APP_NAME" \
    --resource-group "$WEBAPP_RG" \
    --hostname "$CUSTOM_DOMAIN"
  
  echo "Custom domain $CUSTOM_DOMAIN added successfully!"
  echo "Note: It may take a few minutes for the SSL certificate to be provisioned."
}

remove_domain() {
  echo "Removing custom domain $CUSTOM_DOMAIN from $STATIC_APP_NAME..."
  
  validate_azure_cli
  
  echo "Warning: This will remove the custom domain configuration."
  read -p "Are you sure? (y/N): " -r
  if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    echo "Operation cancelled."
    exit 0
  fi
  
  az staticwebapp hostname delete \
    --name "$STATIC_APP_NAME" \
    --resource-group "$WEBAPP_RG" \
    --hostname "$CUSTOM_DOMAIN" \
    --yes
  
  echo "Custom domain $CUSTOM_DOMAIN removed successfully!"
}

main() {
  case "$ACTION" in
    add)
      add_domain
      ;;
    remove)
      remove_domain
      ;;
    list)
      validate_azure_cli
      list_domains
      ;;
    validate)
      validate_azure_cli
      validate_domain
      ;;
    help|*)
      usage
      ;;
  esac
}

main "$@"
