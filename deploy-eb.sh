#!/bin/bash

# Elastic Beanstalk Deployment Script for React Demo
# This script automates the deployment process to AWS Elastic Beanstalk

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ ${1}${NC}"
}

print_error() {
    echo -e "${RED}✗ ${1}${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."

    if ! command_exists node; then
        print_error "Node.js is not installed. Please install Node.js first."
        exit 1
    fi

    if ! command_exists npm; then
        print_error "npm is not installed. Please install npm first."
        exit 1
    fi

    if ! command_exists eb; then
        print_error "EB CLI is not installed. Install it with: pip install awsebcli"
        exit 1
    fi

    if ! command_exists aws; then
        print_warning "AWS CLI is not installed. It's recommended for configuration."
    fi

    print_success "All prerequisites are installed"
}

# Function to install dependencies
install_dependencies() {
    print_info "Installing dependencies..."
    npm install
    print_success "Dependencies installed"
}

# Function to build the application
build_app() {
    print_info "Building application..."
    npm run build

    if [ ! -d "dist" ]; then
        print_error "Build failed - dist directory not found"
        exit 1
    fi

    print_success "Application built successfully"
}

# Function to initialize EB
init_eb() {
    print_info "Initializing Elastic Beanstalk..."

    if [ -f ".elasticbeanstalk/config.yml" ]; then
        print_warning "EB already initialized. Skipping..."
        return
    fi

    eb init
    print_success "Elastic Beanstalk initialized"
}

# Function to create EB environment
create_environment() {
    print_info "Creating Elastic Beanstalk environment..."

    # Check if environment name is provided
    ENV_NAME=${1:-"production"}

    # Check if environment already exists
    if eb list 2>/dev/null | grep -q "$ENV_NAME"; then
        print_warning "Environment '$ENV_NAME' already exists. Skipping creation..."
        return
    fi

    print_info "Creating environment: $ENV_NAME"
    eb create "$ENV_NAME" --single

    print_success "Environment '$ENV_NAME' created successfully"
}

# Function to deploy to EB
deploy() {
    # Get environment name from parameter or default to production-env
    ENV_NAME=${1:-"production-env"}

    print_info "Deploying to Elastic Beanstalk (environment: $ENV_NAME)..."

    # Build the application first
    build_app

    # Verify dist directory exists and has content
    if [ ! -d "dist" ] || [ -z "$(ls -A dist)" ]; then
        print_error "dist/ directory is empty or missing. Build failed."
        exit 1
    fi

    # Show what will be deployed
    print_info "Files to be deployed:"
    print_info "  ✓ dist/ (built React app)"
    print_info "  ✓ src/server.js (Express server)"
    print_info "  ✓ package.json (dependencies)"
    print_info "  ✓ package.production.json (minimal server deps)"
    print_info "  ✓ .ebextensions/ (EB configuration)"
    print_info "  ✓ .platform/hooks/ (npm install hook)"
    echo ""
    print_warning "Source files (src/, vite.config.ts, etc.) will NOT be deployed"
    print_warning "Server will install ONLY Express (~1 MB, not all deps)"
    echo ""

    # Check if environment exists
    print_info "Checking for existing environments..."
    ENV_LIST=$(eb list 2>&1)

    if [ -z "$ENV_LIST" ] || ! echo "$ENV_LIST" | grep -q "$ENV_NAME"; then
        print_warning "No '$ENV_NAME' environment found!"
        echo ""
        read -p "Would you like to create '$ENV_NAME' now? (yes/no): " CREATE_ENV

        if [ "$CREATE_ENV" = "yes" ] || [ "$CREATE_ENV" = "y" ]; then
            print_info "Creating $ENV_NAME environment..."
            print_info "This will take 5-7 minutes. Please wait..."
            echo ""

            eb create "$ENV_NAME" --single

            if [ $? -eq 0 ]; then
                print_success "Environment created successfully!"
                echo ""
                print_info "Now deploying your application..."
                echo ""
            else
                print_error "Failed to create environment"
                exit 1
            fi
        else
            print_error "Cannot deploy without an environment"
            print_info "Create one with: ./deploy-eb.sh create $ENV_NAME single"
            exit 1
        fi
    else
        print_success "Found existing $ENV_NAME environment"
    fi

    # Deploy
    print_info "Uploading to Elastic Beanstalk..."
    eb deploy "$ENV_NAME"

    if [ $? -eq 0 ]; then
        print_success "Deployment completed successfully! 🚀"
        echo ""
        print_info "Next steps:"
        print_info "  - Check status: ./deploy-eb.sh status $ENV_NAME"
        print_info "  - View health: ./deploy-eb.sh health $ENV_NAME"
        print_info "  - Open app: ./deploy-eb.sh open $ENV_NAME"
    else
        print_error "Deployment failed"
        print_info "Check logs with: ./deploy-eb.sh logs $ENV_NAME"
        exit 1
    fi
}

# Function to show status
show_status() {
    print_info "Checking environment status..."
    eb status
}

# Function to view logs
view_logs() {
    print_info "Fetching logs..."
    eb logs
}

# Function to open application in browser
open_app() {
    print_info "Opening application in browser..."
    eb open
}

# Function to terminate environment
terminate_env() {
    print_warning "This will terminate the Elastic Beanstalk environment."
    read -p "Are you sure you want to continue? (yes/no): " confirm

    if [ "$confirm" = "yes" ]; then
        print_info "Terminating environment..."
        eb terminate --all
        print_success "Environment terminated"
    else
        print_info "Termination cancelled"
    fi
}

# Function to show environment health
show_health() {
    ENV_NAME=${1:-"production-env"}
    print_info "Checking environment health for: $ENV_NAME..."
    eb health "$ENV_NAME"
}

# Function to set environment variables
set_env_vars() {
    print_info "Setting environment variables..."

    if [ -f ".env.production" ]; then
        print_info "Found .env.production file. Setting variables..."
        eb setenv $(cat .env.production | grep -v '^#' | xargs)
        print_success "Environment variables set"
    else
        print_warning "No .env.production file found"
        print_info "Usage: eb setenv KEY1=value1 KEY2=value2"
    fi
}

# Function to show usage
show_usage() {
    cat << EOF
${BLUE}Elastic Beanstalk Deployment Script${NC}

Usage: ./deploy-eb.sh [command] [options]

Commands:
    ${GREEN}check${NC}           Check prerequisites
    ${GREEN}install${NC}         Install npm dependencies
    ${GREEN}build${NC}           Build the application
    ${GREEN}init${NC}            Initialize Elastic Beanstalk
    ${GREEN}create${NC} [name] [mode]  Create EB environment (mode: single|loadbalanced, default: single)
    ${GREEN}deploy${NC}          Build and deploy to EB
    ${GREEN}status${NC}          Show environment status
    ${GREEN}health${NC}          Show environment health
    ${GREEN}logs${NC}            View application logs
    ${GREEN}open${NC}            Open application in browser
    ${GREEN}setenv${NC}          Set environment variables from .env.production
    ${GREEN}terminate${NC} [env] Terminate EB environment
    ${GREEN}destroy${NC} [env]   Alias for terminate (like AWS CDK)
    ${GREEN}list${NC}            List all environments
    ${GREEN}full${NC}            Full deployment (check, install, build, deploy)
    ${GREEN}help${NC}            Show this help message

Examples:
    ./deploy-eb.sh check                      # Check prerequisites
    ./deploy-eb.sh init                       # Initialize EB
    ./deploy-eb.sh create my-env              # Create load-balanced environment
    ./deploy-eb.sh create dev-env single      # Create single instance (cheaper)
    ./deploy-eb.sh deploy                     # Deploy to production-env (default)
    ./deploy-eb.sh deploy staging-env         # Deploy to staging-env
    ./deploy-eb.sh status production-env      # Check production-env status
    ./deploy-eb.sh health staging-env         # Check staging-env health
    ./deploy-eb.sh logs dev-env               # View dev-env logs
    ./deploy-eb.sh open production-env        # Open production-env in browser
    ./deploy-eb.sh destroy staging-env        # Destroy staging-env
    ./deploy-eb.sh full                       # Full deployment process

First-time deployment:
    1. ./deploy-eb.sh check
    2. ./deploy-eb.sh init
    3. ./deploy-eb.sh create
    4. ./deploy-eb.sh deploy
    5. ./deploy-eb.sh open

Subsequent deployments:
    ./deploy-eb.sh deploy
EOF
}

# Function for full deployment
full_deployment() {
    print_info "Starting full deployment process..."
    check_prerequisites
    install_dependencies
    build_app
    deploy
    print_success "Full deployment completed!"
}

# Main script logic
case "${1:-help}" in
    check)
        check_prerequisites
        ;;
    install)
        install_dependencies
        ;;
    build)
        build_app
        ;;
    init)
        init_eb
        ;;
    create)
        create_environment "$2"
        ;;
    deploy)
        deploy "$2"
        ;;
    status)
        show_status "$2"
        ;;
    health)
        show_health "$2"
        ;;
    logs)
        view_logs "$2"
        ;;
    open)
        open_app "$2"
        ;;
    setenv)
        set_env_vars
        ;;
    terminate)
        terminate_env "$2"
        ;;
    destroy)
        # Alias for terminate (like AWS CDK)
        terminate_env "$2"
        ;;
    list)
        list_environments
        ;;
    full)
        full_deployment
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac

exit 0

