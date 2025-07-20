# CI/CD Pipeline Documentation

This document explains the comprehensive CI/CD pipeline setup for the MCP Database Servers project, including automated building, testing, security scanning, and deployment of all 13 database Docker images.

## 🏗️ Pipeline Overview

Our CI/CD pipeline consists of three main workflows:

1. **Main CI/CD Pipeline** (`.github/workflows/ci.yml`)
2. **Release Workflow** (`.github/workflows/release.yml`)
3. **Security & Dependencies** (`.github/workflows/security.yml`)

## 📋 Workflow Details

### 1. Main CI/CD Pipeline (`ci.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main`
- Release events
- Weekly scheduled runs (Mondays at 2 AM UTC)

**Jobs:**

#### 🔍 Validate
- Runs project setup validation using `scripts/validate_setup.sh`
- Checks Dockerfile syntax using Hadolint
- Ensures all 13 databases are properly configured

#### 🛡️ Security Scan
- Matrix build across all 13 databases
- Trivy vulnerability scanning for each image
- Uploads SARIF results to GitHub Security tab
- Fails on critical vulnerabilities

#### 🧪 Test Suite
- Sets up test databases (PostgreSQL, MySQL, Redis)
- Installs Python test dependencies
- Runs basic setup and health check tests
- Validates MCP server functionality

#### 🐳 Build & Push
- Matrix build for all 13 database types
- Multi-architecture builds (AMD64 + ARM64)
- Docker layer caching for faster builds
- Pushes to Docker Hub with proper tags
- Only runs on non-PR events

#### 📊 Post-Build Tasks
- Updates Docker Hub descriptions
- Generates build reports
- Creates deployment artifacts

#### 🔗 Integration Tests
- Cross-database integration testing
- Validates multi-database scenarios
- Only runs on main branch pushes

### 2. Release Workflow (`release.yml`)

**Triggers:**
- Manual workflow dispatch with version input

**Features:**
- Semantic version validation
- Tag conflict detection
- Release notes generation
- Multi-architecture Docker builds
- GitHub release creation
- Automated changelog generation

**Usage:**
```bash
# Navigate to Actions tab in GitHub
# Select "Release" workflow
# Click "Run workflow"
# Enter version (e.g., "1.0.0" or "v1.0.0")
# Choose if it's a pre-release
```

### 3. Security & Dependencies (`security.yml`)

**Triggers:**
- Daily scheduled scans (6 AM UTC)
- Push to main (when security files change)
- Manual workflow dispatch

**Security Checks:**
- Dependency vulnerability scanning
- Base image update monitoring
- MCP Toolbox version checking
- Python package auditing
- Security policy compliance
- Automated security reporting

## 🔐 Required Secrets

Configure these secrets in your GitHub repository settings:

### Docker Hub Secrets
```
DOCKER_USERNAME - Your Docker Hub username
DOCKER_PASSWORD - Your Docker Hub access token
```

### Optional Secrets
```
SLACK_WEBHOOK - For Slack notifications (if implemented)
TEAMS_WEBHOOK - For Microsoft Teams notifications (if implemented)
```

## 🏷️ Tagging Strategy

### Automatic Tags (CI Pipeline)
- `latest` - Latest successful build from main branch
- `main-{sha}` - Commit-specific tags from main
- `develop-{sha}` - Commit-specific tags from develop
- `pr-{number}` - Pull request builds

### Release Tags (Release Workflow)
- `v1.0.0` - Semantic version tags
- `1.0.0` - Version without 'v' prefix
- `1.0` - Major.minor tags
- `latest` - Updated on stable releases

## 🚀 Deployment Process

### Automatic Deployment
1. Push to `main` branch
2. CI pipeline validates and tests
3. Builds all 13 database images
4. Pushes to Docker Hub with `latest` tag
5. Updates documentation

### Manual Release
1. Go to GitHub Actions
2. Run "Release" workflow
3. Specify version (e.g., "1.2.3")
4. Pipeline builds and tags all images
5. Creates GitHub release with notes
6. Updates Docker Hub with versioned tags

## 🔧 Local Development Workflow

### Testing Changes Locally
```bash
# Validate setup
./scripts/validate_setup.sh

# Build specific database
./build.sh build-db -d postgres

# Run tests
./tests/run_tests.sh test-quick
```

### Before Pushing
```bash
# Run full validation
./scripts/validate_setup.sh

# Test Docker builds
./build.sh build --no-push

# Run comprehensive tests
./tests/run_tests.sh test
```

## 📊 Monitoring & Observability

### Build Status
- Check GitHub Actions tab for pipeline status
- Review security scan results in Security tab
- Monitor Docker Hub for successful pushes

### Security Monitoring
- Daily vulnerability scans
- Dependency update notifications
- Base image update alerts
- Security compliance checks

### Metrics Tracked
- Build success rate
- Test coverage
- Security scan results
- Image size optimization
- Build duration

## 🛠️ Troubleshooting

### Common Issues

#### 1. Build Failures
```bash
# Check Dockerfile syntax
docker run --rm -i hadolint/hadolint < Dockerfile.postgres

# Validate locally
./scripts/validate_setup.sh
```

#### 2. Test Failures
```bash
# Run tests locally
cd tests
python -m pytest test_basic_setup.py -v

# Check service health
./tests/run_tests.sh logs
```

#### 3. Security Scan Failures
```bash
# Local security scan
docker run --rm -v $(pwd):/workspace aquasec/trivy fs /workspace
```

#### 4. Push Failures
- Verify Docker Hub credentials in GitHub secrets
- Check Docker Hub rate limits
- Ensure repository permissions

### Debug Mode
Enable debug logging by setting `ACTIONS_STEP_DEBUG=true` in repository secrets.

## 🔄 Maintenance Tasks

### Weekly Tasks
- Review security scan results
- Check for dependency updates
- Monitor build performance
- Update documentation

### Monthly Tasks
- Review and update base images
- Audit security policies
- Performance optimization
- Dependency cleanup

### Quarterly Tasks
- Major version updates
- Security audit
- Performance benchmarking
- Documentation review

## 📈 Performance Optimization

### Build Speed
- Docker layer caching enabled
- Multi-stage builds optimized
- Parallel matrix builds
- Dependency caching

### Image Size
- Alpine Linux base images
- Multi-stage builds
- Package cache cleanup
- Minimal dependencies

### Security
- Non-root user execution
- Minimal attack surface
- Regular vulnerability scanning
- Automated updates

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Build Documentation](https://docs.docker.com/engine/reference/commandline/build/)
- [Trivy Security Scanner](https://aquasecurity.github.io/trivy/)
- [Hadolint Dockerfile Linter](https://github.com/hadolint/hadolint)

## 🤝 Contributing to CI/CD

### Adding New Database Support
1. Create `Dockerfile.{database}`
2. Update `build.sh` with new database
3. Add to CI matrix in workflow files
4. Create database-specific tests
5. Update documentation

### Modifying Workflows
1. Test changes in feature branch
2. Use workflow dispatch for testing
3. Monitor Actions tab for results
4. Update documentation
5. Create pull request

### Security Considerations
- Never commit secrets to repository
- Use GitHub secrets for sensitive data
- Regularly rotate access tokens
- Monitor security scan results
- Keep workflows updated