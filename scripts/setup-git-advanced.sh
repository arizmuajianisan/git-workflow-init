#!/bin/bash

# Exit on error and trace execution
set -e
set -o pipefail

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Error handling function
error_exit() {
    echo -e "${RED}❌ Error: $1${NC}" >&2
    exit 1
}

# Cleanup function for error handling
cleanup() {
    # Remove temporary files if they exist
    [ -f "package.tmp.json" ] && rm -f package.tmp.json
    echo -e "${YELLOW}⚠️  Cleanup complete.${NC}"
}

# Set trap for cleanup on exit
trap cleanup EXIT

echo -e "${YELLOW}🚀 Starting Improved Git Workflow Setup${NC}"

# ============================================
# 1. Environment Validation
# ============================================
echo -e "${YELLOW}🔍 Validating environment...${NC}"

# Check Node.js version
if ! command -v node &> /dev/null; then
    error_exit "Node.js is not installed. Please install Node.js v16 or later."
fi

NODE_VERSION=$(node -v | cut -d'v' -f2)
IFS='.' read -ra VERSION_PARTS <<< "$NODE_VERSION"
if [ "${VERSION_PARTS[0]}" -lt 16 ]; then
    error_exit "Node.js v16 or later is required. Current version: $NODE_VERSION"
fi
echo -e "${GREEN}✓ Node.js v$NODE_VERSION is installed${NC}"

# Check npm
if ! command -v npm &> /dev/null; then
    error_exit "npm is not installed. Please install npm."
fi
echo -e "${GREEN}✓ npm is installed${NC}"

# Check git
if ! command -v git &> /dev/null; then
    error_exit "Git is not installed. Please install Git."
fi
echo -e "${GREEN}✓ Git is installed${NC}"

# ============================================
# 2. Project Setup
# ============================================
echo -e "\n${YELLOW}📦 Setting up project...${NC}"

# Initialize package.json if it doesn't exist
if [ ! -f "package.json" ]; then
    echo -e "${YELLOW}ℹ️ Initializing new npm project${NC}"
    npm init -y || error_exit "Failed to initialize npm project"
else
    echo -e "${GREEN}✓ package.json already exists${NC}"
fi

# ============================================
# 3. Install Dependencies with Version Pinning
# ============================================
echo -e "\n${YELLOW}📦 Installing dependencies...${NC}"

# Install core dependencies with specific versions
DEPENDENCIES=(
    "@commitlint/cli@^17.0.0"
    "@commitlint/config-conventional@^17.0.0"
    "husky@^8.0.0"
    "release-it@^16.0.0"
    "@release-it/conventional-changelog@^6.0.0"
    "dotenv-cli@^7.3.0"
    "lint-staged@^13.0.0"
    "prettier@^2.8.0"
    "eslint@^8.0.0"
    "standard-version@^9.5.0"
)

for pkg in "${DEPENDENCIES[@]}"; do
    echo -e "${YELLOW}Installing $pkg...${NC}"
    npm install --save-dev --save-exact "$pkg" || error_exit "Failed to install $pkg"
done

echo -e "${GREEN}✓ Dependencies installed successfully${NC}"

# ============================================
# 4. Configure commitlint
# ============================================
echo -e "\n${YELLOW}🛠️  Configuring commitlint...${NC}"

cat > commitlint.config.js << 'EOL'
/**
 * @type {import('@commitlint/types').UserConfig}
 */
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', [
      'build', 'chore', 'ci', 'docs', 'feat', 'fix', 'perf', 
      'refactor', 'revert', 'style', 'test'
    ]],
    'type-case': [2, 'always', 'lower-case'],
    'type-empty': [2, 'never'],
    'scope-case': [2, 'always', 'lower-case'],
    'subject-case': [2, 'always', 'sentence-case'],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'header-max-length': [2, 'always', 100],
    'body-leading-blank': [1, 'always'],
    'footer-leading-blank': [1, 'always']
  }
};
EOL

echo -e "${GREEN}✓ commitlint configured${NC}"

# ============================================
# 5. Set Up Husky and lint-staged
# ============================================
echo -e "\n${YELLOW}🐶 Setting up Husky and lint-staged...${NC}"

# Initialize husky if not already initialized
if [ ! -d ".husky" ]; then
    npx husky install || error_exit "Failed to initialize husky"
    
    # Create commit-msg hook
    mkdir -p .husky
    echo '#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

npx --no-install commitlint --edit "$1"' > .husky/commit-msg
    
    # Create pre-commit hook
    echo '#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

npx --no-install lint-staged' > .husky/pre-commit
    
    # Make hooks executable
    chmod +x .husky/*
    
    echo -e "${GREEN}✓ Husky hooks configured${NC}"
else
    echo -e "${GREEN}✓ Husky already initialized${NC}"
fi

# Configure lint-staged
echo -e "${YELLOW}📝 Configuring lint-staged...${NC}"

cat > .lintstagedrc.json << 'EOL'
{
  "*.{js,jsx,ts,tsx}": ["eslint --fix", "prettier --write"],
  "*.{json,md,yml,yaml}": ["prettier --write"]
}
EOL

echo -e "${GREEN}✓ Husky and lint-staged configured${NC}"

# ============================================
# 6. Configure release-it
# ============================================
echo -e "\n${YELLOW}🔄 Configuring release-it...${NC}"

cat > .release-it.json << 'EOL'
{
  "$schema": "https://unpkg.com/release-it@17/schema/release-it.json",
  "git": {
    "commitMessage": "chore(release): ${version} [skip ci]",
    "tagName": "v${version}",
    "tagAnnotation": "Release v${version}",
    "requireCleanWorkingDir": true,
    "requireUpstream": true,
    "requireBranch": "main",
    "requireCommits": true
  },
  "github": {
    "release": true,
    "releaseName": "v${version}",
    "releaseNotes": "npx auto-changelog --stdout --commit-limit false --unreleased",
    "assets": ["CHANGELOG.md", "package.json"],
    "tokenRef": "GITHUB_TOKEN"
  },
  "npm": {
    "publish": true,
    "publishPath": ".",
    "access": "public"
  },
  "plugins": {
    "@release-it/conventional-changelog": {
      "preset": "conventionalcommits",
      "infile": "CHANGELOG.md",
      "header": "# Changelog\n\nAll notable changes to this project will be documented in this file.\n\nThe format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),\nand this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).\n",
      "types": [
        { "type": "feat", "section": "✨ Features" },
        { "type": "fix", "section": "🐛 Bug Fixes" },
        { "type": "docs", "section": "📝 Documentation" },
        { "type": "style", "section": "💄 Styles" },
        { "type": "refactor", "section": "♻️ Code Refactoring" },
        { "type": "perf", "section": "⚡ Performance Improvements" },
        { "type": "test", "section": "✅ Tests" },
        { "type": "build", "section": "📦 Build System" },
        { "type": "ci", "section": "🔧 CI Configuration" },
        { "type": "chore", "section": "🔨 Chores" }
      ]
    }
  },
  "hooks": {
    "before:init": ["npm test"],
    "after:bump": "npm run build",
    "after:release": "echo '✅ Successfully released ${name} v${version} to GitHub and npm'"
  }
}
EOL

echo -e "${GREEN}✓ release-it configured${NC}"

# ============================================
# 7. Update package.json Scripts
# ============================================
echo -e "\n${YELLOW}📝 Updating package.json scripts...${NC}"

# Using jq if available, otherwise use sed
if command -v jq &> /dev/null; then
    jq '{
        scripts: {
            "prepare": "husky install",
            "release": "standard-version",
            "release:minor": "standard-version --release-as minor",
            "release:major": "standard-version --release-as major",
            "release:dry-run": "standard-version --dry-run",
            "lint": "eslint . --ext .js,.jsx,.ts,.tsx",
            "lint:fix": "eslint . --ext .js,.jsx,.ts,.tsx --fix",
            "format": "prettier --write .",
            "test": "echo \"No tests specified\" && exit 0"
        },
        "lint-staged": {
            "*.{js,jsx,ts,tsx}": ["eslint --fix", "prettier --write"],
            "*.{json,md,yml,yaml}": ["prettier --write"]
        }
    } * .' package.json > package.tmp.json && \
    mv package.tmp.json package.json
else
    # Fallback to sed if jq is not available
    cat > package.tmp.json << 'EOL'
{
  "scripts": {
    "prepare": "husky install",
    "release": "standard-version",
    "release:minor": "standard-version --release-as minor",
    "release:major": "standard-version --release-as major",
    "release:dry-run": "standard-version --dry-run",
    "lint": "eslint . --ext .js,.jsx,.ts,.tsx",
    "lint:fix": "eslint . --ext .js,.jsx,.ts,.tsx --fix",
    "format": "prettier --write .",
    "test": "echo \"No tests specified\" && exit 0"
  },
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{json,md,yml,yaml}": ["prettier --write"]
  }
}
EOL
    # Merge with existing package.json
    jq -s '.[0] * .[1]' package.json package.tmp.json > package.tmp2.json && \
    mv package.tmp2.json package.json && \
    rm -f package.tmp.json
fi

echo -e "${GREEN}✓ package.json scripts updated${NC}"

# ============================================
# 8. Create Configuration Files
# ============================================

# Create .editorconfig if it doesn't exist
if [ ! -f ".editorconfig" ]; then
    echo -e "${YELLOW}📝 Creating .editorconfig...${NC}"
    cat > .editorconfig << 'EOL'
# Editor configuration, see https://editorconfig.org
root = true

[*]
charset = utf-8
indent_style = space
indent_size = 2
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false
EOL
    echo -e "${GREEN}✓ .editorconfig created${NC}"
fi

# Create .npmrc if it doesn't exist
if [ ! -f ".npmrc" ]; then
    echo -e "${YELLOW}📝 Creating .npmrc...${NC}"
    echo -e "save-exact=true\naudit-level=high\nfund=false" > .npmrc
    echo -e "${GREEN}✓ .npmrc created${NC}"
fi

# Create .env file if it doesn't exist
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}🔑 Creating .env file...${NC}"
    echo "# GitHub Personal Access Token" > .env
    echo "GITHUB_TOKEN=your_github_token_here" >> .env
    echo -e "${YELLOW}⚠️  Please update the GITHUB_TOKEN in the .env file with your actual GitHub token${NC}"
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

# Update .gitignore if needed
if [ ! -f ".gitignore" ]; then
    echo -e "${YELLOW}📋 Creating .gitignore file...${NC}"
    cat > .gitignore << 'EOL'
# Dependencies
node_modules/
.pnp
.pnp.js

# Testing
coverage/

# Production
build/
dist/

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Editor directories and files
.idea/
.vscode/
*.suo
*.ntvs*
*.njsproj
*.sln
*.sw?

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
EOL
    echo -e "${GREEN}✓ .gitignore created${NC}"
else
    echo -e "${GREEN}✓ .gitignore already exists${NC}"
fi

# ============================================
# 9. Initialize Git Repository
# ============================================
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}🔧 Initializing git repository...${NC}"
    git init || error_exit "Failed to initialize git repository"
    git add . || error_exit "Failed to stage files"
    git commit -m "chore: initial commit" || \
        echo -e "${YELLOW}⚠️  Could not create initial commit${NC}"
    echo -e "${YELLOW}⚠️  Don't forget to add a remote repository with 'git remote add origin <repository-url>'${NC}"
else
    echo -e "${GREEN}✓ Git repository already initialized${NC}"
fi

# ============================================
# 10. Create GitHub Actions Workflow
# ============================================
mkdir -p .github/workflows

cat > .github/workflows/release.yml << 'EOL'
name: Release

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm test

      - name: Create Release
        if: github.ref == 'refs/heads/main'
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
        run: npx standard-version --no-verify

      - name: Push changes and tags
        if: github.ref == 'refs/heads/main'
        run: |
          git config --global user.name 'GitHub Action'
          git config --global user.email 'action@github.com'
          git push --follow-tags origin main
EOL

echo -e "${GREEN}✓ GitHub Actions workflow created${NC}"

# ============================================
# Completion
# ============================================
echo -e "\n${GREEN}🎉 Improved Git workflow setup complete!${NC}"
echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Update the GITHUB_TOKEN in the .env file with your GitHub personal access token"
echo "2. Review and customize the configuration files:"
echo "   - .release-it.json"
echo "   - commitlint.config.js"
echo "   - .eslintrc.js"
echo "   - .prettierrc"
echo "3. Make your first commit with a conventional commit message, e.g.:"
echo "   git add ."
echo "   git commit -m 'chore: initial commit'"
echo "4. Push your code to GitHub"
echo "5. Create your first release with: npm run release"
echo -e "\n${GREEN}Happy coding! 🚀${NC}"

exit 0
