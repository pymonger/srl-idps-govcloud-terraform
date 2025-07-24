#!/bin/bash

# Setup script for pre-commit hooks
set -e

echo "🚀 Setting up pre-commit hooks for Terraform project..."

# Check if pre-commit is installed
if ! command -v pre-commit &> /dev/null; then
    echo "📦 Installing pre-commit..."

    # Check if we're on macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install pre-commit
        else
            echo "❌ Homebrew not found. Please install pre-commit manually:"
            echo "   pip install pre-commit"
            exit 1
        fi
    else
        # For other systems, use pip
        pip install pre-commit
    fi
else
    echo "✅ pre-commit is already installed"
fi

# Install pre-commit hooks
echo "🔧 Installing pre-commit hooks..."
pre-commit install

# Install commit-msg hook for commitlint
echo "📝 Installing commit-msg hook..."
pre-commit install --hook-type commit-msg

# Install additional tools
echo "🛠️  Installing additional tools..."

# Install TFLint
if ! command -v tflint &> /dev/null; then
    echo "📦 Installing TFLint..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install tflint
    else
        curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
    fi
fi

# Install Checkov
if ! command -v checkov &> /dev/null; then
    echo "📦 Installing Checkov..."
    pip install checkov
fi

# Install tfsec
if ! command -v tfsec &> /dev/null; then
    echo "📦 Installing tfsec..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install tfsec
    else
        curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
    fi
fi

# Install Infracost
if ! command -v infracost &> /dev/null; then
    echo "📦 Installing Infracost..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install infracost
    else
        curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh
    fi
fi

# Install terraform-docs
if ! command -v terraform-docs &> /dev/null; then
    echo "📦 Installing terraform-docs..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install terraform-docs
    else
        curl -s https://raw.githubusercontent.com/terraform-docs/terraform-docs/master/scripts/install.sh | bash
    fi
fi

# Install yamllint
if ! command -v yamllint &> /dev/null; then
    echo "📦 Installing yamllint..."
    pip install yamllint
fi

# Install markdownlint
if ! command -v markdownlint &> /dev/null; then
    echo "📦 Installing markdownlint..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        npm install -g markdownlint-cli
    else
        npm install -g markdownlint-cli
    fi
fi

# Install shellcheck
if ! command -v shellcheck &> /dev/null; then
    echo "📦 Installing shellcheck..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install shellcheck
    else
        sudo apt-get install shellcheck
    fi
fi

# Install shfmt
if ! command -v shfmt &> /dev/null; then
    echo "📦 Installing shfmt..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install shfmt
    else
        curl -s https://raw.githubusercontent.com/mvdan/sh/master/cmd/shfmt/install.sh | bash
    fi
fi

# Install detect-secrets
if ! command -v detect-secrets &> /dev/null; then
    echo "📦 Installing detect-secrets..."
    pip install detect-secrets
fi

# Initialize detect-secrets baseline
if [ ! -f .secrets.baseline ]; then
    echo "🔍 Initializing detect-secrets baseline..."
    detect-secrets scan --baseline .secrets.baseline
fi

# Run initial pre-commit check
echo "🔍 Running initial pre-commit check..."
pre-commit run --all-files

echo "✅ Pre-commit setup complete!"
echo ""
echo "📋 Available commands:"
echo "   pre-commit run --all-files    # Run all hooks on all files"
echo "   pre-commit run                # Run hooks on staged files"
echo "   pre-commit run <hook-name>    # Run specific hook"
echo "   pre-commit autoupdate         # Update hook versions"
echo ""
echo "🔧 Individual tools:"
echo "   tflint                        # Terraform linting"
echo "   checkov                       # Security scanning"
echo "   tfsec                         # Security scanning"
echo "   infracost breakdown          # Cost estimation"
echo "   terraform-docs               # Documentation generation"
echo ""
echo "📚 Documentation:"
echo "   https://pre-commit.com/"
echo "   https://github.com/terraform-linters/tflint"
echo "   https://www.checkov.io/"
echo "   https://aquasecurity.github.io/tfsec/"
echo "   https://www.infracost.io/"
