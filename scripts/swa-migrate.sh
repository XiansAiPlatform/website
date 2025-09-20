#!/bin/bash

set -euo pipefail

# Script to find and manage existing static web apps for domain migration
# This script helps identify existing deployments using the xians.ai domain

SUBSCRIPTION=${AZ_SUBSCRIPTION:-"XiansAi Prod"}
CUSTOM_DOMAIN=${CUSTOM_DOMAIN:-"xians.ai"}
NEW_STATIC_APP_NAME=${UI_APP_NAME:-"xians-public-app"}
NEW_WEBAPP_RG=${RESOURCE_GROUP:-"rg-xians-public-app"}

ACTION=${1:-"help"}

usage() {
  echo "Usage: $0 <action>"
  echo "Actions:"
  echo "  find      - Find all static web apps in the subscription"
  echo "  check     - Check which apps are using the custom domain"
  echo "  cleanup   - Remove custom domain from old apps (interactive)"
  echo "  list-rg   - List all resource groups with static web apps"
  echo "  help      - Show this help message"
  echo ""
  echo "Environment variables:"
  echo "  AZ_SUBSCRIPTION (default: XiansAi Prod)"
  echo "  CUSTOM_DOMAIN (default: xians.ai)"
  echo "  UI_APP_NAME (default: xians-public-app)"
  echo "  RESOURCE_GROUP (default: rg-xians-public-app)"
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

find_static_web_apps() {
  echo "Finding all Static Web Apps in subscription '$SUBSCRIPTION'..."
  echo ""
  
  # Get all static web apps
  APPS=$(az staticwebapp list --query "[].{Name:name, ResourceGroup:resourceGroup, DefaultHostname:defaultHostname, Location:location}" -o table 2>/dev/null)
  
  if [ -z "$APPS" ] || [ "$APPS" = "[]" ]; then
    echo "No Static Web Apps found in the subscription."
    return 0
  fi
  
  echo "$APPS"
  echo ""
  
  # Count total apps
  APP_COUNT=$(az staticwebapp list --query "length([])" -o tsv 2>/dev/null || echo "0")
  echo "Total Static Web Apps found: $APP_COUNT"
}

check_domain_usage() {
  echo "Checking which Static Web Apps are using domain '$CUSTOM_DOMAIN'..."
  echo ""
  
  # Get all static web apps
  APPS_JSON=$(az staticwebapp list 2>/dev/null || echo "[]")
  
  if [ "$APPS_JSON" = "[]" ]; then
    echo "No Static Web Apps found in the subscription."
    return 0
  fi
  
  # Parse each app and check for custom domains
  echo "$APPS_JSON" | jq -r '.[] | "\(.name)|\(.resourceGroup)"' | while IFS='|' read -r app_name resource_group; do
    if [ -n "$app_name" ] && [ -n "$resource_group" ]; then
      echo "Checking app: $app_name (Resource Group: $resource_group)"
      
      # Get custom domains for this app
      DOMAINS=$(az staticwebapp hostname list \
        --name "$app_name" \
        --resource-group "$resource_group" \
        --query "[].name" -o tsv 2>/dev/null || echo "")
      
      if [ -n "$DOMAINS" ]; then
        echo "  Custom domains: $DOMAINS"
        
        # Check if our target domain is in use
        if echo "$DOMAINS" | grep -q "^$CUSTOM_DOMAIN$"; then
          echo "  *** FOUND: $CUSTOM_DOMAIN is configured on this app ***"
          
          # Get default hostname for reference
          DEFAULT_HOST=$(az staticwebapp show \
            --name "$app_name" \
            --resource-group "$resource_group" \
            --query "defaultHostname" -o tsv 2>/dev/null || echo "")
          
          if [ -n "$DEFAULT_HOST" ]; then
            echo "  Default hostname: $DEFAULT_HOST"
          fi
        fi
      else
        echo "  No custom domains configured"
      fi
      echo ""
    fi
  done
}

list_resource_groups() {
  echo "Listing all resource groups with Static Web Apps..."
  echo ""
  
  # Get all resource groups that contain static web apps
  az staticwebapp list --query "sort_by([].{ResourceGroup:resourceGroup, Count:length([])}[], &ResourceGroup)" -o table 2>/dev/null || echo "No Static Web Apps found"
}

cleanup_old_domains() {
  echo "Interactive cleanup of custom domain '$CUSTOM_DOMAIN' from existing apps..."
  echo "This will help you remove the domain from old deployments before adding it to the new one."
  echo ""
  
  # Get all static web apps
  APPS_JSON=$(az staticwebapp list 2>/dev/null || echo "[]")
  
  if [ "$APPS_JSON" = "[]" ]; then
    echo "No Static Web Apps found in the subscription."
    return 0
  fi
  
  FOUND_DOMAIN=false
  
  # Parse each app and check for custom domains
  echo "$APPS_JSON" | jq -r '.[] | "\(.name)|\(.resourceGroup)"' | while IFS='|' read -r app_name resource_group; do
    if [ -n "$app_name" ] && [ -n "$resource_group" ]; then
      # Get custom domains for this app
      DOMAINS=$(az staticwebapp hostname list \
        --name "$app_name" \
        --resource-group "$resource_group" \
        --query "[].name" -o tsv 2>/dev/null || echo "")
      
      # Check if our target domain is in use
      if echo "$DOMAINS" | grep -q "^$CUSTOM_DOMAIN$"; then
        FOUND_DOMAIN=true
        echo "Found '$CUSTOM_DOMAIN' on app: $app_name (Resource Group: $resource_group)"
        
        # Skip if this is our new app
        if [ "$app_name" = "$NEW_STATIC_APP_NAME" ] && [ "$resource_group" = "$NEW_WEBAPP_RG" ]; then
          echo "  This is the target app - skipping removal"
          continue
        fi
        
        echo "  Do you want to remove '$CUSTOM_DOMAIN' from this app? (y/N)"
        read -r REPLY
        if [[ "$REPLY" =~ ^[Yy]$ ]]; then
          echo "  Removing custom domain..."
          az staticwebapp hostname delete \
            --name "$app_name" \
            --resource-group "$resource_group" \
            --hostname "$CUSTOM_DOMAIN" \
            --yes
          echo "  Domain removed successfully!"
        else
          echo "  Skipped."
        fi
        echo ""
      fi
    fi
  done
  
  if [ "$FOUND_DOMAIN" = false ]; then
    echo "Domain '$CUSTOM_DOMAIN' not found on any existing Static Web Apps."
  fi
}

main() {
  validate_azure_cli
  
  case "$ACTION" in
    find)
      find_static_web_apps
      ;;
    check)
      check_domain_usage
      ;;
    cleanup)
      cleanup_old_domains
      ;;
    list-rg)
      list_resource_groups
      ;;
    help|*)
      usage
      ;;
  esac
}

main "$@"
