# Git Workflow Initializer

A collection of scripts and documentation to help you set up a professional Git workflow for your projects. Choose between a simple or advanced workflow based on your project's needs.

## 🚀 Features

### Simple Workflow (`setup-git-simple.sh`)
- ✅ Commit message validation with commitlint
- 🔄 Automated versioning with semantic-release
- 📜 Automatic CHANGELOG generation
- 🐶 Git hooks with Husky
- 🔒 GitHub releases integration
- 🛠️ Zero-configuration setup

### Advanced Workflow (`setup-git-advanced.sh`)
All features from the simple workflow, plus:
- 🧪 Automated testing integration
- 🔍 Code quality checks (ESLint, Prettier)
- 🔄 CI/CD pipeline setup
- 🔒 Security scanning
- 📦 Docker support
- 🏗️ Monorepo support

## 📋 Prerequisites

- Node.js (v14 or later)
- npm (comes with Node.js)
- Git
- GitHub repository (for GitHub releases)

## 🚀 Quick Start

### Simple Workflow

For most projects, the simple workflow provides everything you need:

```bash
# Download the setup script
curl -O https://raw.githubusercontent.com/arizmuajianisan/git-workflow-init/main/scripts/setup-git-simple.sh

# Make it executable and run
chmod +x setup-git-simple.sh
./setup-git-simple.sh
```

### Advanced Workflow

For larger projects or teams that need more robust tooling:

```bash
# Download the advanced setup script
curl -O https://raw.githubusercontent.com/arizmuajianisan/git-workflow-init/main/scripts/setup-git-advanced.sh

# Make it executable and run
chmod +x setup-git-advanced.sh
./setup-git-advanced.sh
```

## 🤔 Which Workflow Should I Choose?

### Choose Simple If:
- You're working on a small to medium project
- You want minimal configuration
- You don't need CI/CD integration
- You're the sole developer or in a small team

### Choose Advanced If:
- You're working on a large project or monorepo
- You need automated testing and code quality checks
- You want CI/CD pipeline setup
- You're working in a team environment
- You need additional security scanning

## 📚 Documentation

- [Simple Workflow Guide](setup-git-simple.md)
- [Advanced Workflow Guide](setup-git-advance.md)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)

## 🔧 Troubleshooting

### Common Issues

#### Commit Message Validation Fails
- Ensure your commit message follows the format: `type(scope): description`
- Check for typos in the commit type
- Make sure there's a space after the type and colon

#### Release Fails
- Make sure you have a clean working directory
- Ensure you have push access to the repository
- Verify your GitHub token has the correct permissions

#### GitHub Release Not Created
- Check that the `GITHUB_TOKEN` environment variable is set
- Verify the token has the `repo` scope
- Make sure the repository has been pushed to GitHub

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guide](CONTRIBUTING.md) to get started.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Conventional Commits](https://www.conventionalcommits.org/)
- [commitlint](https://commitlint.js.org/)
- [Husky](https://typicode.github.io/husky/)
- [release-it](https://github.com/release-it/release-it)
- [Semantic Versioning](https://semver.org/)
