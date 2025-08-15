#!/bin/bash

# Exit on error
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🚀 Starting Git Workflow Setup${NC}"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}❌ Node.js is not installed. Please install Node.js v14 or later and try again.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Node.js is installed${NC}"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo -e "${YELLOW}❌ npm is not installed. Please install npm and try again.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ npm is installed${NC}"

# Initialize package.json if it doesn't exist
if [ ! -f "package.json" ]; then
    echo -e "${YELLOW}ℹ️ Initializing new npm project${NC}"
    npm init -y
else
    echo -e "${GREEN}✓ package.json already exists${NC}"
fi

# Install dependencies
echo -e "${YELLOW}📦 Installing dependencies...${NC}"
npm install --save-dev @commitlint/cli @commitlint/config-conventional husky release-it @release-it/conventional-changelog dotenv-cli

echo -e "${GREEN}✓ Dependencies installed successfully${NC}"

# Configure commitlint
echo -e "${YELLOW}🛠️  Configuring commitlint...${NC}"
cat > commitlint.config.js << 'EOL'
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      ['build', 'chore', 'ci', 'docs', 'feat', 'fix', 'perf', 'refactor', 'revert', 'style', 'test']
    ]
  }
};
EOL

echo -e "${GREEN}✓ commitlint configured${NC}"

# Set up Husky
echo -e "${YELLOW}🐶 Setting up Husky...${NC}"
# Initialize Husky if not already initialized
if [ ! -d ".husky" ]; then
    npx husky init
    # Create commit-msg hook
    echo '#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

npx --no-install commitlint --edit "$1"' > .husky/commit-msg
    chmod +x .husky/commit-msg
    echo -e "${GREEN}✓ Husky setup complete${NC}"
else
    echo -e "${GREEN}✓ Husky already initialized${NC}"
fi

# Configure release-it
echo -e "${YELLOW}🔄 Configuring release-it...${NC}"
cat > .release-it.json << 'EOL'
{
  "$schema": "https://unpkg.com/release-it@17/schema/release-it.json",
  "git": {
    "commitMessage": "chore(release): ${version}",
    "tagName": "v${version}",
    "tagAnnotation": "Release v${version}",
    "requireCleanWorkingDir": true,
    "requireUpstream": true,
    "requireBranch": "main"
  },
  "github": {
    "release": true,
    "releaseName": "v${version}",
    "tokenRef": "GITHUB_TOKEN"
  },
  "npm": {
    "publish": false
  },
  "plugins": {
    "@release-it/conventional-changelog": {
      "preset": "conventionalcommits",
      "infile": "CHANGELOG.md",
      "header": "# Changelog\n\nAll notable changes to this project will be documented in this file.\n\nThe format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),\nand this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).\n",
      "types": [
        { "type": "feat", "section": "Added" },
        { "type": "fix", "section": "Fixed" },
        { "type": "docs", "section": "Documentation" },
        { "type": "style", "section": "Style" },
        { "type": "refactor", "section": "Refactored" },
        { "type": "perf", "section": "Performance" },
        { "type": "test", "section": "Tests" },
        { "type": "build", "section": "Build System" },
        { "type": "ci", "section": "CI/CD" },
        { "type": "chore", "section": "Chores" }
      ],
      "releaseRules": [
        { "type": "feat", "release": "minor" },
        { "type": "fix", "release": "patch" },
        { "type": "perf", "release": "patch" },
        { "type": "refactor", "release": "patch" },
        { "type": "BREAKING CHANGE", "release": "major" }
      ]
    }
  },
  "hooks": {
    "after:release": "echo '✅ Successfully released ${name} v${version} to GitHub.'"
  }
}
EOL

echo -e "${GREEN}✓ release-it configured${NC}"

# Update package.json scripts
echo -e "${YELLOW}📝 Updating package.json scripts...${NC}"

# Use jq if available, otherwise use sed
if command -v jq &> /dev/null; then
    # Using jq to update package.json
    jq '.scripts += {"release": "dotenv -e .env -- release-it", "prepare": "husky"}' package.json > package.tmp.json && mv package.tmp.json package.json
else
    # Fallback to sed if jq is not available
    sed -i.bak '/"scripts": {/a \    "release": "dotenv -e .env -- release-it",\n    "prepare": "husky",' package.json
    rm -f package.json.bak 2> /dev/null || true
fi

echo -e "${GREEN}✓ package.json scripts updated${NC}"

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
    echo -e "node_modules/\n.env\n*.log\n.DS_Store" > .gitignore
else
    # Check if required entries exist in .gitignore
    for pattern in "node_modules/" ".env" "*.log" ".DS_Store"; do
        if ! grep -q "^${pattern}$" .gitignore 2>/dev/null; then
            echo "$pattern" >> .gitignore
        fi
    done
    echo -e "${GREEN}✓ .gitignore updated${NC}"
fi

# Initialize git if not already done
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}🔧 Initializing git repository...${NC}"
    git init
    echo -e "${YELLOW}⚠️  Don't forget to add a remote repository with 'git remote add origin <repository-url>'${NC}"
else
    echo -e "${GREEN}✓ Git repository already initialized${NC}"
fi

echo -e "\n${GREEN}🎉 Git workflow setup complete!${NC}"
echo -e "\nNext steps:"
echo "1. Update the GITHUB_TOKEN in the .env file with your GitHub personal access token"
echo "2. Make your first commit with a conventional commit message, e.g.:"
echo "   git add ."
echo "   git commit -m 'chore: initial commit'"
echo "3. Create your first release with: npm run release"

exit 0
