# GitHub Reusable Workflows

## Overview

A curated list of [GitHub Reusable Workflows](https://docs.github.com/en/actions/sharing-automations/reusing-workflows) focusing on enterprise CI/CD patterns for popular programming languages.

The workflows are designed to be used by application workflows through a [workflaw_call](https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows#workflow_call).


## Supported languages

1. Node.js/JavaScript
2. Python 
3. Go
4. Java
5. Python

## Workflows list

### Node/JavaScript workflows

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

### Csharp workflows

#### csharp-build.yml

Performs the following actions:

1. Lint code.
2. Run unit tests.
3. Build the applicaiton.
4. Scan code for vulnerabilities. 
5. Create docker image abd push it to the default registry  ghcr.io.
6. Scan the docker image for vulnerabilities.

Requirements:

  1. GitHub permissions
      - Read and Write workflow permissions under Settings/Actions/General.

Input parameters

| Name                    | Default   | Required | Description          |
| :---                    | :----     | :------: | :----                |
| app-name                |           | yes      | Application name     |
| language                | csharp    | no       | Programming language |
| git-fetch-depth         | 1         | no       | Some GitHub Actions require the whole commit history to calculate the next SemVer version or extract git tags used for labels and container image tags. Use 0 to retrieve the whole commit history. |
| dotnet-version          | 9.0.300   | no       | .Net version used to build, test and package the application |
| dotnet-tools-restore    | true      | no       | Should .Net tools like `csharpier` linter be restored from the project as a Nuget package or installed globally (false) |
| dotnet-linter-csharpier   | true    | no        | If true, use csharpier for linting |
| dotnet-linter-roslynator  | false   | no        | If true, use roslynator for linting |  
| dotnet-test-verbosity     | normal  | no        | Verbosity level for .NET tests. Default normal; can be quiet, minimal, normal, detailed, or diagnostic |  
| security-trivy            | true    | no        | If true, perform Trivy scan of docker image |
| security-snyk             | false   | no        | If true, perform Snyk scan of docker image |
| registry                  | ghcr.io | no        | Container registry to push to for the docker image |
| docker-context            | .       | no        | Context for Docker build. Default src/NetWebApi.API |
| docker-file               | ./Dockerfile   | no        | Dockerfile path. Default ./Dockerfile; can be set to a custom Dockerfile path |
| docker-push            | true       | no        | Push the Docker image to the registry. Default true |

#### csharp-deploy.yml

Deploy docker container imate to a target platform. By default it deploys into local k8s cluster with the help of local GitHub runner and helm v3. 

Requirements:

  1. GitHub permissions
      - Read permissions under Settings/Actions/General.

  2. Target: lcoal-k8s.
      - Local GitHub runner
      - Local Kubernetes cluster
      - Helm v3

Input parameters

| Name                    | Default   | Required | Description          |
| :---                    | :----     | :------: | :----                |
| image-name              |           | yes      | Name of the Docker image to deploy     |
| image-tag               | latest    | no       | Docker image tag  |
| namespace               | default   | no       | Kubernetes namespace to deploy where the image is deployed to |
| registry                | ghcr.io   | no        | Container registry to pull the docker image from |
| chart                   | app     | no        | Path to the helm chart in the GitHub repo. Example: 'deploy/helm/netwebapi' |
| release-name            | 9.0.300   | no       | Release name for the Helm chart |
| helm-version            | helm3     | no        | Helm version to use for deployment into Kubernetess cluster |
| target                  | local-k8s | no      | Deployment target - local k8s cluster |

