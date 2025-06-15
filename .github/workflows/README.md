## How to Use

Use the `dev-node.yml` reusable workflow to run a complete Node.js pipeline.

*Example: Calling the Node Pipeline Workflow**

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [ main ]

jobs:
  use-pipeline:
    uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/workflows/dev-node.yml@v1
    with:
      node-version: '20'
      lint-command: 'npm run lint'
      build-command: 'npm run build'
      test-command: 'npm test'
      package-command: 'npm pack'
      artifact-name: 'node-package'
      run_trivy: true
      run_grype: true
```

## Stages in `dev-node.yml`

The workflow includes the following CI/CD stages:

| Stage         | Purpose                                             |
|---------------|-----------------------------------------------------|
| `lint`        | Runs lint checks with user-defined command          |
| `build`       | Builds the Node.js project                          |
| `unitTest`    | Executes Jest-based unit tests                      |
| `securityScan`| Scans for vulnerabilities using CodeQL              |
| `versioning`  | Generates Git version tags                          |
| `dockerBuildAndPush` | Builds and pushes Docker image to GHCR       |
| `dockerScan`  | Performs vulnerability scans with Trivy and Grype   |
| `package`     | Packages application as a Node.js artifact          |
| `dashboard`   | Publishes results to GitHub dashboard               |

## Inputs for `dev-node.yml`

| Input             | Type     | Default          | Description                          |
|-------------------|----------|------------------|--------------------------------------|
| node-version      | string   | '20'             | Node.js version                      |
| working-directory | string   | '.'              | Project root directory               |
| lint-command      | string   | 'npm run lint'   | Linting command                      |
| build-command     | string   | 'npm run build'  | Build command                        |
| test-command      | string   | 'npm test'       | Test command                         |
| package-command   | string   | 'npm pack'       | Package command                      |
| artifact-name     | string   | 'node-package'   | Name of artifact                     |
| run_trivy         | boolean  | true             | Enable Trivy scan                    |
| run_grype         | boolean  | true             | Enable Grype scan                    |
| contine-on-error  | boolean  | true             | Continue on lint/test errors         |

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

> **Note:** Not all pipelines use every stage. You can opt-in to stages via inputs or choose from templates like `run_trivy` or `run_grype`.

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