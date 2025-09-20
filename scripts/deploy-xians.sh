#!/bin/bash

set -euo pipefail

# Main deployment script for Xians.ai platform
# This script orchestrates the complete deployment process including DNS migration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PUBLIC_APP_DIR="$PROJECT_DIR/public-app"

# Default configuration for Xians.ai production deployment
export UI_APP_NAME=${UI_APP_NAME:-"xians-public-app"}
export RESOURCE_GROUP=${RESOURCE_GROUP:-"rg-xians-public-app"}
export LOCATION=${LOCATION:-"westeurope"}
export AZ_SUBSCRIPTION=${AZ_SUBSCRIPTION:-"XiansAi Prod"}
export CUSTOM_DOMAIN=${CUSTOM_DOMAIN:-"xians.ai"}
export UI_SKU=${UI_SKU:-"Free"}

ACTION=${1:-"help"}

usage() {
  echo "Xians.ai Platform Deployment Script"
  echo "====================================="
  echo ""
  echo "Usage: $0 <action>"
  echo ""
  echo "Actions:"
  echo "  full      - Complete deployment (build + create + migrate domain)"
  echo "  build     - Build the application only"
  echo "  create    - Create Static Web App only
  deploy    - Deploy application files only"
  echo "  migrate   - Handle domain migration from existing apps"
  echo "  domain    - Configure custom domain"
  echo "  status    - Show current deployment status"
  echo "  cleanup   - Clean up old deployments"
  echo "  help      - Show this help message"
  echo ""
  echo "Environment variables (with defaults):"
  echo "  UI_APP_NAME=$UI_APP_NAME"
  echo "  RESOURCE_GROUP=$RESOURCE_GROUP"
  echo "  LOCATION=$LOCATION"
  echo "  AZ_SUBSCRIPTION=$AZ_SUBSCRIPTION"
  echo "  CUSTOM_DOMAIN=$CUSTOM_DOMAIN"
  echo "  UI_SKU=$UI_SKU"
  echo ""
  echo "Example usage:"
  echo "  ./deploy-xians.sh full              # Complete deployment"
  echo "  ./deploy-xians.sh status            # Check status"
  echo "  ./deploy-xians.sh migrate           # Migrate domain only"
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

validate_prerequisites() {
  log "Validating prerequisites..."
  
  # Check if we're in the right directory
  if [ ! -d "$PUBLIC_APP_DIR" ]; then
    echo "Error: public-app directory not found at $PUBLIC_APP_DIR"
    echo "Please run this script from the website root directory"
    exit 1
  fi
  
  # Check if package.json exists
  if [ ! -f "$PUBLIC_APP_DIR/package.json" ]; then
    echo "Error: package.json not found in $PUBLIC_APP_DIR"
    exit 1
  fi
  
  # Check Node.js
  if ! command -v npm >/dev/null 2>&1; then
    echo "Error: npm is not installed"
    exit 1
  fi
  
  # Check Azure CLI
  if ! command -v az >/dev/null 2>&1; then
    echo "Error: Azure CLI is not installed"
    exit 1
  fi
  
  log "Prerequisites validated successfully"
}

build_application() {
  log "Building the application..."
  
  cd "$PUBLIC_APP_DIR"
  
  # Install dependencies
  log "Installing dependencies..."
  npm ci
  
  # Build the application
  log "Building application..."
  npm run build
  
  # Verify build output
  if [ ! -d "dist" ]; then
    echo "Error: Build failed - dist directory not found"
    exit 1
  fi
  
  log "Application built successfully"
  cd "$SCRIPT_DIR"
}

create_static_web_app() {
  log "Creating Static Web App..."
  
  # Capture the output to extract the deployment token
  CREATE_OUTPUT=$(mktemp)
  if ! "$SCRIPT_DIR/swa-create.sh" | tee "$CREATE_OUTPUT"; then
    echo "Error: Failed to create Static Web App"
    rm -f "$CREATE_OUTPUT"
    exit 1
  fi
  
  # Extract deployment token from output
  DEPLOYMENT_TOKEN=$(grep "Deployment token:" "$CREATE_OUTPUT" | cut -d' ' -f3)
  rm -f "$CREATE_OUTPUT"
  
  if [ -z "$DEPLOYMENT_TOKEN" ]; then
    echo "Warning: Could not extract deployment token from output"
  else
    export AZURE_STATIC_WEB_APPS_API_TOKEN="$DEPLOYMENT_TOKEN"
  fi
  
  log "Static Web App created successfully"
}

deploy_application() {
  log "Deploying application files..."
  
  if ! "$SCRIPT_DIR/swa-deploy.sh"; then
    echo "Error: Failed to deploy application"
    exit 1
  fi
  
  log "Application deployed successfully"
}

handle_domain_migration() {
  log "Handling domain migration..."
  
  # First, check what apps are using the domain
  log "Checking existing domain usage..."
  "$SCRIPT_DIR/swa-migrate.sh" check
  
  echo ""
  log "Do you want to proceed with domain migration? This will:"
  log "1. Remove the domain from any existing apps"
  log "2. Add the domain to the new app"
  echo ""
  read -p "Continue? (y/N): " -r
  
  if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    log "Domain migration skipped"
    return 0
  fi
  
  # Clean up old domain assignments
  log "Cleaning up old domain assignments..."
  "$SCRIPT_DIR/swa-migrate.sh" cleanup
  
  # Add domain to new app
  log "Adding domain to new app..."
  "$SCRIPT_DIR/swa-domain.sh" add
  
  log "Domain migration completed"
}

configure_domain_only() {
  log "Configuring custom domain..."
  
  # Validate domain configuration
  "$SCRIPT_DIR/swa-domain.sh" validate
  
  echo ""
  read -p "Proceed with domain configuration? (y/N): " -r
  
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    "$SCRIPT_DIR/swa-domain.sh" add
  else
    log "Domain configuration skipped"
  fi
}

show_status() {
  log "Current deployment status:"
  echo ""
  
  # Show current subscription
  CURRENT_SUB=$(az account show --query "name" -o tsv 2>/dev/null || echo "Not logged in")
  echo "Current subscription: $CURRENT_SUB"
  
  # Check if static web app exists
  if az staticwebapp show --name "$UI_APP_NAME" --resource-group "$RESOURCE_GROUP" >/dev/null 2>&1; then
    echo "Static Web App: ✓ EXISTS"
    
    # Get default hostname
    DEFAULT_HOST=$(az staticwebapp show \
      --name "$UI_APP_NAME" \
      --resource-group "$RESOURCE_GROUP" \
      --query "defaultHostname" -o tsv 2>/dev/null || echo "")
    
    if [ -n "$DEFAULT_HOST" ]; then
      echo "Default hostname: $DEFAULT_HOST"
    fi
    
    # Check custom domains
    echo "Custom domains:"
    "$SCRIPT_DIR/swa-domain.sh" list
    
  else
    echo "Static Web App: ✗ NOT FOUND"
  fi
  
  echo ""
  echo "Configuration:"
  echo "  App Name: $UI_APP_NAME"
  echo "  Resource Group: $RESOURCE_GROUP"
  echo "  Location: $LOCATION"
  echo "  Custom Domain: $CUSTOM_DOMAIN"
}

cleanup_old_deployments() {
  log "Cleaning up old deployments..."
  
  # Show all static web apps
  "$SCRIPT_DIR/swa-migrate.sh" find
  
  echo ""
  log "This will help you identify and clean up old Static Web Apps"
  log "Use the swa-delete.sh script to remove unwanted deployments"
  
  echo ""
  read -p "Do you want to see which apps are using your domain? (y/N): " -r
  
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    "$SCRIPT_DIR/swa-migrate.sh" check
  fi
}

full_deployment() {
  log "Starting full deployment process..."
  
  validate_prerequisites
  build_application
  create_static_web_app
  deploy_application
  handle_domain_migration
  
  log "Deployment completed successfully!"
  echo ""
  show_status
}

main() {
  case "$ACTION" in
    full)
      full_deployment
      ;;
    build)
      validate_prerequisites
      build_application
      ;;
    create)
      create_static_web_app
      ;;
    deploy)
      deploy_application
      ;;
    migrate)
      handle_domain_migration
      ;;
    domain)
      configure_domain_only
      ;;
    status)
      show_status
      ;;
    cleanup)
      cleanup_old_deployments
      ;;
    help|*)
      usage
      ;;
  esac
}

# Ensure we're in the scripts directory
cd "$SCRIPT_DIR"

main "$@"
