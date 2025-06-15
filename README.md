# Platform GitHub Actions Library

This repository contains **reusable GitHub Actions workflows** that standardize CI/CD pipelines across our organization. These workflows are centrally maintained by the Platform Engineering team and are meant to be consumed via `workflow_call` from individual service repositories.

## What’s Included

| Workflow Name       | Purpose                         | Language / Use Case   |
|---------------------|---------------------------------|-----------------------|
| `test-node.yml`     | Run tests for Node.js services  | Node.js (npm, yarn)   |
| `lint-python.yml`   | Lint Python code with flake8    | Python                |
| `build-java.yml`    | Build and test Java projects    | Java / Maven / Gradle |
| `deploy.yml`        | Deploy to environment/stage     | Any (requires setup)  |
| ...                 | ...                             | ...                   |
|                     |                                 |                       |

## How to Use a Reusable Workflow

From your service repository, create a workflow like this:

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [ main ]

jobs:
  test:
    uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/workflows/test-node.yml@v1
    with:
      node-version: '20'
```

## Stages

To promote consistency and scalability, our reusable workflows follow a standardized set of CI/CD stages. These stages help teams implement reliable pipelines and allow platform tooling (e.g., dashboards, security gates) to plug in seamlessly.

| Stage            | Purpose                                                        | Typical Tools / Examples                          |
|------------------|----------------------------------------------------------------|---------------------------------------------------|
| `checkout`       | Fetch source code, set up environment                          | `actions/checkout`                                |
| `setup`          | Generate pipeline-wide metadata and context used across stages | image tag name, normalized branch name, timestamps, versioning |
| `language-setup` | Install required language runtimes for downstream execution    | `setup-node`, `setup-python`, `setup-go`, `setup-dotnet` |
| `lint`           | Code formatting, dependency scan, secret detection             | `eslint`, `flake8`, `gitleaks`, `trivy fs`, `npm audit` |
| `test`           | Unit tests, code coverage, static analysis                     | `jest`, `pytest`, `SonarQube`, `CodeQL`, `semgrep`|
| `build`          | Compile or prepare source artifacts                            | `npm run build`, `mvn package`, `go build`        |
| `package`        | Create deployable artifacts (e.g., containers, zips, SBOMs)    | `docker build`, `zip`, `cyclonedx`, `trivy image` |
| `security`       | Deep scanning (SAST, image vuln, license)                      | `Veracode`, `Snyk`, `Trivy`, `CodeQL`, `OSS Review` |
| `deploy`         | Deploy to environment (dev, staging, prod)                     | `kubectl`, `helm`, `aws deploy`, `argo`           |
| `notify`         | Send status notifications or post-results                      | Slack, Microsoft Teams, GitHub PR status updates  |

> **Note:** Not all pipelines use every stage. You can opt-in to stages via inputs or choose from templates like `dev-build.yml` or `rel-build.yml`.

**Example Workflow Using All Stages**:

```yaml
jobs:
  lint:
    uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/workflows/lint-node.yml@v1

  test:
    uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/workflows/test-node.yml@v1
    needs: lint

  build:
    uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/workflows/build-node.yml@v1
    needs: test

  package:
    uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/workflows/package-node.yml@v1
    needs: build

  security:
    uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/workflows/security-scan.yml@v1
    needs: package
    with:
      image-name: my-app
      image-tag: 1.0

  deploy:
    uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/workflows/deploy.yml@v1
    needs: security
    with:
      environment: staging
```

## Available Inputs

Inputs vary by workflow. Refer to the top of each workflow YAML file or [input reference section](#workflow-inputs).

## Example Starter Templates

We provide starter templates in the /templates folder:

- sample-node.yml
- sample-python.yml

Copy and customize one for your service to get started quickly.

## Versioning

Workflows should be consumed using tagged versions, not main.

✅ **Recommended**:

```yaml
uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/workflows/test-node.yml@v1
```

❌ **Avoid**:

```yaml
uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/workflows/test-node.yml@main
```

## Contributing

Want to add a new workflow or improve an existing one?

See [CONTRIBUTING.md](./CONTRIBUTING.md) for:

- Naming conventions
- Coding standards
- Testing tips
- Review checklist

## Support

- GitHub Issues: Open an issue
- Maintainers: @platform-dev1, @platform-dev2

## Security

- Secrets must be passed via secrets input or GitHub Environments
- No hardcoded credentials or tokens
- No direct org resource references unless templated

## Workflow Inputs

Below are common inputs for popular workflows:

**test-node.yml**:

| Input        | Type   | Default | Description            |
|--------------|--------|---------|------------------------|
| node-version | string | '18'    | Node.js version to use |

**test-python.yml**:

| Input          | Type   | Default | Description           |
|----------------|--------|---------|-----------------------|
| python-version | string | '3.11'  | Python version to use |

