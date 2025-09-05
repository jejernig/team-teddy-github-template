#!/bin/bash
# Configure Database Secrets for GitHub Actions
# This script helps set up GitHub Secrets for Supabase integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project information
PROJECT_NAME="{{PROJECT_NAME}}"
COMPANY_NAME="{{COMPANY_NAME}}"
DATABASE_PROVIDER="{{DATABASE_PROVIDER}}"

echo -e "${BLUE}🔐 Configuring database secrets for ${PROJECT_NAME}${NC}"

# Check if GitHub CLI is installed
check_github_cli() {
    echo -e "${YELLOW}📋 Checking GitHub CLI installation...${NC}"
    
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI not found. Please install it first:${NC}"
        echo -e "${BLUE}   https://cli.github.com/manual/installation${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ GitHub CLI is installed${NC}"
        gh --version
    fi
}

# Check if user is authenticated with GitHub
check_github_auth() {
    echo -e "${YELLOW}🔑 Checking GitHub authentication...${NC}"
    
    if ! gh auth status &> /dev/null; then
        echo -e "${YELLOW}⚠️  Not authenticated with GitHub. Please run:${NC}"
        echo -e "${BLUE}   gh auth login${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ Authenticated with GitHub${NC}"
    fi
}

# Interactive secret configuration
configure_supabase_secrets() {
    echo -e "${BLUE}🏗️  Configuring Supabase secrets...${NC}"
    echo
    echo -e "${YELLOW}Please provide the following information from your Supabase project:${NC}"
    echo -e "${BLUE}You can find these values in your Supabase project dashboard > Settings > API${NC}"
    echo
    
    # Get Supabase project information
    read -p "Supabase Project Reference ID: " SUPABASE_PROJECT_REF
    read -p "Supabase Region (e.g., us-east-1): " SUPABASE_REGION
    read -s -p "Supabase Database Password: " SUPABASE_DB_PASSWORD
    echo
    read -p "Supabase Project URL: " SUPABASE_URL
    read -p "Supabase Anonymous Key: " SUPABASE_ANON_KEY
    read -s -p "Supabase Service Role Key: " SUPABASE_SERVICE_ROLE_KEY
    echo
    read -s -p "Supabase Access Token (for CLI): " SUPABASE_ACCESS_TOKEN
    echo
    
    # Validate required fields
    if [[ -z "$SUPABASE_PROJECT_REF" ]] || [[ -z "$SUPABASE_DB_PASSWORD" ]] || [[ -z "$SUPABASE_URL" ]]; then
        echo -e "${RED}❌ Missing required Supabase information. Please try again.${NC}"
        exit 1
    fi
    
    # Generate connection strings based on Context7 research
    SESSION_URL="postgres://postgres.${SUPABASE_PROJECT_REF}:${SUPABASE_DB_PASSWORD}@aws-0-${SUPABASE_REGION:-us-east-1}.pooler.supabase.com:5432/postgres"
    TRANSACTION_URL="postgres://postgres.${SUPABASE_PROJECT_REF}:${SUPABASE_DB_PASSWORD}@aws-0-${SUPABASE_REGION:-us-east-1}.pooler.supabase.com:6543/postgres"
    DIRECT_URL="postgresql://postgres:${SUPABASE_DB_PASSWORD}@db.${SUPABASE_PROJECT_REF}.supabase.co:5432/postgres"
    
    echo -e "${YELLOW}📝 Generated connection strings:${NC}"
    echo -e "${BLUE}Session Mode (Migrations): ${SESSION_URL}${NC}"
    echo -e "${BLUE}Transaction Mode (App): ${TRANSACTION_URL}${NC}"
    echo -e "${BLUE}Direct Connection: ${DIRECT_URL}${NC}"
    echo
    
    # Set GitHub secrets
    echo -e "${YELLOW}🚀 Setting GitHub secrets...${NC}"
    
    # Basic Supabase configuration
    gh secret set SUPABASE_PROJECT_REF --body "$SUPABASE_PROJECT_REF"
    gh secret set SUPABASE_REGION --body "${SUPABASE_REGION:-us-east-1}"
    gh secret set SUPABASE_DB_PASSWORD --body "$SUPABASE_DB_PASSWORD"
    gh secret set SUPABASE_PROJECT_ID --body "$SUPABASE_PROJECT_REF"  # Often the same
    
    # Connection strings
    gh secret set DATABASE_URL --body "$TRANSACTION_URL"  # For application use
    gh secret set DIRECT_URL --body "$SESSION_URL"       # For migrations
    
    # Public configuration
    gh secret set NEXT_PUBLIC_SUPABASE_URL --body "$SUPABASE_URL"
    gh secret set NEXT_PUBLIC_SUPABASE_ANON_KEY --body "$SUPABASE_ANON_KEY"
    
    # Private keys
    if [[ -n "$SUPABASE_SERVICE_ROLE_KEY" ]]; then
        gh secret set SUPABASE_SERVICE_ROLE_KEY --body "$SUPABASE_SERVICE_ROLE_KEY"
    fi
    
    if [[ -n "$SUPABASE_ACCESS_TOKEN" ]]; then
        gh secret set SUPABASE_ACCESS_TOKEN --body "$SUPABASE_ACCESS_TOKEN"
    fi
    
    echo -e "${GREEN}✅ GitHub secrets configured successfully${NC}"
}

# Configure environment-specific secrets
configure_environment_secrets() {
    echo -e "${YELLOW}🌍 Would you like to configure environment-specific secrets? (y/N)${NC}"
    read -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        for env in "staging" "production"; do
            echo -e "${BLUE}Configuring ${env} environment:${NC}"
            
            read -p "${env} Supabase Project Reference ID: " ENV_PROJECT_REF
            read -s -p "${env} Supabase Database Password: " ENV_DB_PASSWORD
            echo
            
            if [[ -n "$ENV_PROJECT_REF" ]] && [[ -n "$ENV_DB_PASSWORD" ]]; then
                # Generate environment-specific connection strings
                ENV_SESSION_URL="postgres://postgres.${ENV_PROJECT_REF}:${ENV_DB_PASSWORD}@aws-0-${SUPABASE_REGION:-us-east-1}.pooler.supabase.com:5432/postgres"
                ENV_TRANSACTION_URL="postgres://postgres.${ENV_PROJECT_REF}:${ENV_DB_PASSWORD}@aws-0-${SUPABASE_REGION:-us-east-1}.pooler.supabase.com:6543/postgres"
                
                # Set environment-specific secrets
                gh secret set "${env^^}_DATABASE_URL" --body "$ENV_TRANSACTION_URL"
                gh secret set "${env^^}_DIRECT_URL" --body "$ENV_SESSION_URL"
                gh secret set "${env^^}_SUPABASE_PROJECT_REF" --body "$ENV_PROJECT_REF"
                
                echo -e "${GREEN}✅ ${env} environment configured${NC}"
            else
                echo -e "${YELLOW}⚠️  Skipping ${env} environment configuration${NC}"
            fi
        done
    fi
}

# Create local environment file
create_local_env() {
    echo -e "${YELLOW}💻 Creating local .env.local file...${NC}"
    
    # Check if .env.local already exists
    if [[ -f ".env.local" ]]; then
        echo -e "${YELLOW}⚠️  .env.local already exists. Creating .env.local.template instead.${NC}"
        ENV_FILE=".env.local.template"
    else
        ENV_FILE=".env.local"
    fi
    
    cat > "$ENV_FILE" << EOF
# Local Development Environment Variables
# Generated by Team Teddy Development template

# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=${SUPABASE_URL}
NEXT_PUBLIC_SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}

# Database URLs (for local development - update for production)
DATABASE_URL=postgresql://postgres:postgres@localhost:54322/postgres
DIRECT_URL=postgresql://postgres:postgres@localhost:54322/postgres

# Application Configuration
NEXT_PUBLIC_APP_NAME=${PROJECT_NAME}
NEXT_PUBLIC_COMPANY_NAME=${COMPANY_NAME}

# Development Settings
NODE_ENV=development
EOF

    echo -e "${GREEN}✅ Local environment file created: $ENV_FILE${NC}"
    echo -e "${BLUE}   Update the DATABASE_URL values for your actual local setup${NC}"
}

# Display configuration summary
display_summary() {
    echo
    echo -e "${GREEN}🎉 Database secrets configuration completed!${NC}"
    echo
    echo -e "${BLUE}📋 Summary of configured secrets:${NC}"
    echo -e "${YELLOW}• SUPABASE_PROJECT_REF${NC}"
    echo -e "${YELLOW}• SUPABASE_REGION${NC}" 
    echo -e "${YELLOW}• SUPABASE_DB_PASSWORD${NC}"
    echo -e "${YELLOW}• DATABASE_URL${NC}"
    echo -e "${YELLOW}• DIRECT_URL${NC}"
    echo -e "${YELLOW}• NEXT_PUBLIC_SUPABASE_URL${NC}"
    echo -e "${YELLOW}• NEXT_PUBLIC_SUPABASE_ANON_KEY${NC}"
    echo -e "${YELLOW}• SUPABASE_SERVICE_ROLE_KEY (if provided)${NC}"
    echo -e "${YELLOW}• SUPABASE_ACCESS_TOKEN (if provided)${NC}"
    echo
    echo -e "${BLUE}🔍 To view all secrets: gh secret list${NC}"
    echo -e "${BLUE}📚 Documentation: docs/GITHUB_SECRETS.md${NC}"
    echo
    echo -e "${BLUE}Next steps:${NC}"
    echo -e "${YELLOW}1. Test your GitHub Actions workflows${NC}"
    echo -e "${YELLOW}2. Verify database connections in CI/CD${NC}"
    echo -e "${YELLOW}3. Monitor secret usage and rotate regularly${NC}"
}

# Main execution
main() {
    echo -e "${BLUE}🏁 Starting database secrets configuration...${NC}"
    
    # Only run if database provider is Supabase
    if [[ "$DATABASE_PROVIDER" != "supabase" ]]; then
        echo -e "${YELLOW}⚠️  Database provider is not Supabase ($DATABASE_PROVIDER). Skipping secrets configuration.${NC}"
        exit 0
    fi
    
    check_github_cli
    check_github_auth
    configure_supabase_secrets
    configure_environment_secrets
    create_local_env
    display_summary
}

# Show help if requested
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    echo "Configure Database Secrets for GitHub Actions"
    echo
    echo "Usage: $0"
    echo
    echo "This script will interactively configure GitHub Secrets for Supabase integration."
    echo "Make sure you have the GitHub CLI installed and are authenticated."
    echo
    echo "Required information:"
    echo "• Supabase Project Reference ID"
    echo "• Supabase Database Password"
    echo "• Supabase Project URL"
    echo "• Supabase Anonymous Key"
    echo "• Supabase Service Role Key"
    echo "• Supabase Access Token"
    echo
    exit 0
fi

# Run main function
main "$@"