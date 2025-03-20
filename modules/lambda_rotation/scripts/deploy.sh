#!/bin/bash
set -e

# Parameters
LAMBDA_NAME=${1:-"rotate_password"}
CERT_PATH=${CERT_PATH:-"certs/global-bundle.pem"}

# Dependency Checks
command -v pip3 >/dev/null 2>&1 || { echo "pip3 is not installed. Aborting."; exit 1; }
command -v zip >/dev/null 2>&1 || { echo "zip is not installed. Aborting."; exit 1; }

# Clean old build
echo "Cleaning old build artifacts..."
rm -rf package && mkdir package

# Install Python packages into package dir
echo "Installing dependencies..."
pip3 install -r requirements.txt -t package/

# Copy Lambda code & certificates
echo "Copying Lambda code and certificates..."
cp lambda_function.py package/
mkdir -p package/certs
cp $CERT_PATH package/certs/

# Zip everything
echo "Creating deployment package..."
cd package
zip -r ../lambda-deploy.zip .
cd ..

# Check if ZIP was created successfully
if [ ! -f "lambda-deploy.zip" ]; then
  echo "❌ Packaging failed. lambda-deploy.zip not found!"
  exit 1
fi

echo "Packaging complete: lambda-deploy.zip"

# Inform the user about Terraform deployment
echo "Now you can run 'terraform apply' manually inside your environment."