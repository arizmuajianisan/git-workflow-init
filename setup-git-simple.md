# Simple Git Workflow Setup

This guide explains how to set up a lightweight Git workflow using commit-lint, husky, and release-it for automated versioning and changelog generation. This is a simplified version of the workflow, perfect for small to medium projects.

## Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Setup](#quick-setup)
- [What's Included](#whats-included)
  - [Commit Linting](#commit-linting)
  - [Git Hooks](#git-hooks)
  - [Automated Versioning](#automated-versioning)
  - [Changelog Generation](#changelog-generation)
- [Workflow](#workflow)
  - [Making Changes](#making-changes)
  - [Creating a Release](#creating-a-release)
- [Commit Message Format](#commit-message-format)
- [Troubleshooting](#troubleshooting)

## Features

- ✅ **Commit Message Validation**: Ensures all commit messages follow the Conventional Commits specification
- 🔄 **Automated Versioning**: Bumps version numbers based on commit types (feat → minor, fix → patch, etc.)
- 📜 **Changelog Generation**: Automatically generates a CHANGELOG.md file
- 🐶 **Git Hooks**: Prevents bad commits and enforces commit message format
- 🔒 **GitHub Integration**: Creates GitHub releases automatically

## Prerequisites

- Node.js (v14 or later)
- npm (comes with Node.js)
- Git
- A GitHub repository (for GitHub releases)

## Quick Setup

1. Download the setup script:
   ```bash
   curl -O https://raw.githubusercontent.com/your-org/git-workflow-init/main/scripts/setup-git-simple.sh
   ```

2. Make it executable and run:
   ```bash
   chmod +x setup-git-simple.sh
   ./setup-git-simple.sh
   ```

3. Follow the on-screen instructions to complete the setup.

## What's Included

### Commit Linting

Validates commit messages against the [Conventional Commits](https://www.conventionalcommits.org/) specification. Example valid messages:
- `feat: add user authentication`
- `fix(api): handle null response`
- `docs: update README`

### Git Hooks

- **commit-msg**: Validates commit messages
- **prepare**: Ensures husky is properly set up

### Automated Versioning

Version numbers follow [Semantic Versioning](https://semver.org/):
- `feat` → minor version bump (0.1.0 → 0.2.0)
- `fix` → patch version bump (0.1.0 → 0.1.1)
- `BREAKING CHANGE` → major version bump (0.1.0 → 1.0.0)

### Changelog Generation

Automatically generates a `CHANGELOG.md` file with categorized changes:
```markdown
# Changelog

## [1.0.0] - 2023-01-01

### Added
- New user authentication system

### Fixed
- Login page layout issues
```

## Workflow

### Making Changes

1. Create a new branch:
   ```bash
   git checkout -b type/description
   # Example: git checkout -b feat/user-authentication
   ```

2. Make your changes and stage them:
   ```bash
   git add .
   ```

3. Commit with a descriptive message:
   ```bash
   git commit -m "type(scope): description"
   # Example: git commit -m "feat(auth): add login form"
   ```

### Creating a Release

1. Ensure all changes are committed and pushed
2. Run the release command:
   ```bash
   npm run release
   ```
3. Follow the interactive prompts to select the version bump
4. The script will:
   - Bump the version in package.json
   - Update CHANGELOG.md
   - Create a git tag
   - Push changes to GitHub
   - Create a GitHub release

## Commit Message Format

```
<type>(<scope>): <description>
[optional body]
[optional footer(s)]
```

### Types:
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code changes that don't fix bugs or add features
- `test`: Adding or modifying tests
- `chore`: Build process or tooling changes

### Examples:
```
feat(auth): add password reset flow
fix(api): handle null user in middleware
docs: update installation instructions
```

## Troubleshooting

### Commit Message Validation Fails
- Ensure your commit message follows the correct format
- Check for typos in the commit type
- Make sure there's a space after the type and colon

### Release Fails
- Make sure you have a clean working directory
- Ensure you have push access to the repository
- Verify your GitHub token has the correct permissions

### GitHub Release Not Created
- Check that the `GITHUB_TOKEN` environment variable is set
- Verify the token has the `repo` scope
- Make sure the repository has been pushed to GitHub

---

For more advanced features like CI/CD integration, code quality checks, and automated testing, check out the [advanced workflow](setup-git-advance.md).

```bash
   git checkout main
   git pull origin main
```

2. Run the release command:
   ```bash
   npm run release
   ```

   This will:
   - Bump the version (following semver)
   - Update the changelog
   - Create a git tag
   - Push changes to GitHub
   - Create a GitHub release

## Commit Message Format

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:
- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code changes that neither fix bugs nor add features
- `perf`: Performance improvements
- `test`: Adding or modifying tests
- `chore`: Changes to the build process or auxiliary tools

Example commit messages:
- `feat: add user authentication`
- `fix: resolve login issue with special characters`
- `docs: update README with installation instructions`
- `chore: update dependencies`

## Troubleshooting

### Husky not running hooks:
- Ensure the `.husky` directory has execute permissions:
  ```bash
  chmod +x .husky/*
  ```
  (Unix-like systems only)

### GitHub token issues:
- Ensure your GitHub token has the `repo` scope
- Verify the token is correctly set in your `.env` file
- Make sure the `.env` file is in your project root

### Release fails due to dirty working directory:
- Commit or stash your changes before running the release
- Ensure all files are either committed or gitignored

### Commit message validation fails:
- Make sure your commit message follows the conventional commit format
- Run `git commit` without the `-m` flag to open an editor with a template

### Release fails with authentication errors:
- Double-check your `GITHUB_TOKEN` in the `.env` file
- Ensure the token has the necessary permissions for the repository
- If using a GitHub organization, make sure the token has access to the organization's repositories
