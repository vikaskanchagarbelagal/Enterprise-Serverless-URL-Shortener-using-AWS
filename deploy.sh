#!/bin/bash
set -e

# -----------------------------
# Load environment variables
# -----------------------------
if [ ! -f .env ]; then
  echo "Error: .env file not found!"
  exit 1
fi
export $(grep -v '^#' .env | xargs)

echo "Using AWS Region: $AWS_REGION"
echo "Project Name: $PROJECT_NAME"
echo "API Base: $API_BASE"

# -----------------------------
# Package Lambda functions
# -----------------------------
echo "Packaging Lambda functions..."
cd lambda

zip -r create_url.zip create_url.py
zip -r redirect_url.zip redirect_url.py
mv create_url.zip ../terraform/
mv redirect_url.zip ../terraform/
cd ..

# -----------------------------
# Inject API_BASE into frontend
# -----------------------------
echo "Updating frontend with API_BASE..."
FRONTEND_FILE="frontend/index.html"
TMP_FILE="frontend/index.tmp.html"

# Replace placeholder {{API_BASE}} with actual API_BASE
sed "s|{{API_BASE}}|$API_BASE|g" "$FRONTEND_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$FRONTEND_FILE"

# -----------------------------
# Terraform deployment
# -----------------------------
echo "Initializing Terraform..."
cd terraform

terraform init

echo "Applying Terraform (auto-approve)..."
terraform apply -auto-approve

cd ..
echo "Deployment completed!"
echo "Frontend URL: $(terraform -chdir=terraform output -raw frontend_url)"
echo "API Base URL: $(terraform -chdir=terraform output -raw api_url)"