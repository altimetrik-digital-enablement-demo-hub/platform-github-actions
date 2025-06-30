# Platform GitHub Actions Library

This repository contains **reusable GitHub Actions workflows** that standardize CI/CD pipelines across our organization. These workflows are centrally maintained by the Platform Engineering team and are meant to be consumed via `workflow_call` from individual service repositories.


## Goals

This library aims to:

- **Centralized Workflows and Actions management:** Ensure consistent standards and best practices are followed across numerous GitHub repositories.
- **Reduced duplication:** Eliminate the need for developers to rewrite common tasks repeatedly, saving time and reducing the risk of errors.
- **Enforce security best practices:** Build a more secure CI/CD pipeline by embedding security checks (static code analysis, dependency scanning, container scanning, etc) into your automated workflows, allowing for continuous monitoring, early detection and rapid response to potential threats.
- **Faster onboarding:** Enable new projects to quickly adopt CI/CD automation through using workflows tailored for their technology stacks, clear documentation, and reduced manual setup.
- **Reliable deployments:** Introduce changes consistently across various deployment environments.
- **Modular and testable design:** Add and test new features easily without disruping existing workflows and actions.

## Repository Structure

```plaintext
.github/
├── workflows/    # Reuseable templates
│    ├── node-build.yml   
│    ├── node-deploy.yml  
└── actions/       # Reusable custom actions
    ├── common/      # Common CI/CD stages
    │   ├── codeql.yml
    │   ├── docker-build-publish.yml
    │   ├── git-package.yml
    │   ├── git-tag-generation.yml
    │   ├── github-dashboard.yml
    │   ├── grype-scan.yml
    │   ├── trivy-scan.yml
    │   ├── helm-deployment.yml
    │   └── ...
    └── node/        # Node.js-specific workflows
        ├── build.yml
        ├── lint.yml
        ├── setup.yml
        └── ...
    ├── java/
    ├── python/
    ├── go
    └── ...

```

---

## What's Included

| Location                      | Purpose                                                  |
|------------------------------|----------------------------------------------------------|
| `.github/actions/common/`    | Shared, language-agnostic actions (scans, packaging, tagging, deployment) |
| `.github/actions/node/`      | Node.js-specific actions only                            |
| `.github/workflows/`         | Reusable workflows combining multiple actions using `workflow_call` |

---

## How to Use

- All reusable workflows live under the `.github/workflows/` folder.
- These workflows use `workflow_call` and can be referenced in service repositories via: ` uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/workflows/dev-node-build.yml@v0.0.1` 
- You can visit [reference section](./.github/workflows/README.md) to understand complete setup.

```yaml
jobs:
  use-dev-pipeline:
    uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/workflows/dev-node.yml@<ref>
    with:
      node-version: '20'
      lint-command: 'npm run lint'
      ...
```

## Action Format

Each custom action must include:

- A `README.md`
- An `action.yml` file with:
  - Inputs clearly described with types, defaults, and required flags
  - **Convention over Configuration:** Use as much as possible reasonable defaults for input parameters and make them optional. 
  - `runs` section clearly defined (`composite` or `docker`)
  - Descriptive, minimal, and reusable logic

---

## Workflow Format

Reusable workflows should follow a stage-based format:

```yaml
jobs:
  lint:
    ...
  build:
    needs: lint
    ...
  test:
    needs: lint
    ...
  security:
    needs: build
    ...
  deploy:
    needs: security
    ...
```

- Use `needs:` to define dependencies on other jobs
- Keep environment setup (e.g., Node version) as `parameterized inputs`

## Naming Conventions

- ✅ Use **kebab-case** for file and folder names:  
  _e.g., `docker-build-push.yml`, `jest-unit-test/`_

- ✅ Prefix actions with their domain for clarity:  
  _e.g., `node/lint`, `common/grype-scan`_

- ✅ Workflows should be named by use case or language:  
  _e.g., `dev-node.yml`, `release-java.yml`_

---

## Security Standards

- ❌ Never hardcode tokens or secrets  
- ✅ Use GitHub-provided secrets (`GITHUB_TOKEN`) or GitHub Environments  
  - ✅ Allow (`GITHUB_TOKEN`) with read/write permissions for - `Actions`, `Contents`, `Deployments`, `Pages`, `Secrets` & `Workflows`

---

## Contributing - Adding new Reusable Workflows and Actions

### Documentation

A new Reusable Workflow or Composite Action must include at least:

- A one-liner description in the `README.md` table
- Inputs documented (in table format if possible)
- Example usage (for both actions and workflows)

---

### Testing & Validation

Before merging:

- Lint YAML syntax of new Workflows and Actions.
- Create a test Workflow to test new Reusable Workflow and Composite Actions.
- Provide a link to test Workflow in the PR.
- Test deployments in local Kubernetes clusters using local GitHub Runners.

## 🐹 Go Applications

### Project Structure Conventions

This platform follows standard Go project layout conventions. By default, it expects your main application entry point to be located in the `./cmd` directory:

```
your-go-app/
├── cmd/
│   └── main.go              # Application entry point (default location)
├── pkg/
│   └── yourpackage/
│       ├── yourpackage.go
│       └── yourpackage_test.go
├── go.mod
├── go.sum
└── Dockerfile
```

### Customizing Main Package Location

If your project uses a different structure, you can customize the main package path using the `main-package-path` input:

#### Common Go Project Layouts:

1. **Standard layout (default)** - Main package in `./cmd`:
   ```yaml
   uses: osru-leu/platform-github-actions/.github/workflows/go-build.yml@main
   with:
     app-name: my-app
     # main-package-path: './cmd' (default)
   ```

2. **Simple project** - Main package in root directory:
   ```yaml
   uses: osru-leu/platform-github-actions/.github/workflows/go-build.yml@main
   with:
     app-name: my-app
     main-package-path: '.'
   ```

3. **Multi-binary project** - Specific app directory:
   ```yaml
   uses: osru-leu/platform-github-actions/.github/workflows/go-build.yml@main
   with:
     app-name: my-app
     main-package-path: './cmd/my-app'
   ```

4. **Alternative structure** - Custom directory:
   ```yaml
   uses: osru-leu/platform-github-actions/.github/workflows/go-build.yml@main
   with:
     app-name: my-app
     main-package-path: './src'
   ```

### Example Usage

Here's a complete example of using the Go build workflow:

```yaml
# .github/workflows/dev.yml
name: Dev Pipeline

on:
  push:
    branches: ["**"]
  pull_request:
    branches: [main]

jobs:
  build:
    uses: osru-leu/platform-github-actions/.github/workflows/go-build.yml@main
    with:
      app-name: calculator-app
      go-version: '1.23'
      main-package-path: './cmd'  # Optional: defaults to './cmd'
      registry: ghcr.io
      docker-context: .
      docker-file: ./Dockerfile
```

### Go Action Inputs Reference

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `app-name` | Name of the application (used for binary name) | ✅ | - |
| `go-version` | Go version to use | ❌ | `'1.24'` |
| `main-package-path` | Path to the main package | ❌ | `'./cmd'` |
| `registry` | Container registry URL | ❌ | `'ghcr.io'` |
| `docker-context` | Context for Docker build | ❌ | `'.'` |
| `docker-file` | Dockerfile path | ❌ | `'./Dockerfile'` |
| `docker-push` | Push Docker image to registry | ❌ | `true` |

## 🔧 Other Technologies

### .NET Applications

[Coming soon]

### Node.js Applications

[Coming soon]

## 🚀 Getting Started

1. **Create your application** following the expected project structure
2. **Add a workflow file** in `.github/workflows/` that calls the appropriate reusable workflow
3. **Customize inputs** as needed for your specific project structure
4. **Push your code** to trigger the CI/CD pipeline

## 🤝 Contributing

When adding new actions or workflows:

1. **Follow naming conventions** - Use descriptive names with technology prefixes
2. **Provide sensible defaults** - Make actions work out-of-the-box for standard layouts
3. **Allow customization** - Add input parameters for common variations
4. **Document thoroughly** - Update this README with usage examples

## 📚 Documentation

- [Go Actions Architecture](/.github/actions/go/README.md)
- [Workflow Examples](/examples/)

---

Built with ❤️ for streamlined CI/CD across all your projects.
