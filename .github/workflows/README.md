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

### csharp-deploy

Lint, build, test, scan, package into docker container and deploy. By default it deploys into local k8s cluster with the help of local GitHub runner and helm v3. 

Requirements:

  1. GitHub permissions
      - Read and Write workflow permissions under Settings/Actions/General.

  2. Target: lcoal-k8s.
      - Local GitHub runner
      - Local Kubernetes cluster
      - Helm v3

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
| security-trivy            | true    | no        | If true, perform Trivy scan of docker image |
| security-snyk             | false   | no        | If true, perform Snyk scan of docker image |
| registry                  | ghcr.io | no        | Container registry to push to for the docker image |
| chart                     | app     | no        | Path to the helm chart in the GitHub repo. Example: 'deploy/helm/netwebapi' |
| helm-version              | HEML3   | no        | Helm version to use for deployment into Kubernetess cluster |
| target                    | local-k8s | no      | Deployment target - local k8s cluster |

```mermaid
flowchart TD
  A[Trigger: workflow_call] --> B[Job: lint]
  B --> B1{dotnet-linter-csharpier?}
  B1 -- true --> B1a[Run: csharpier (composite)]
  B --> B2{dotnet-linter-roslynator?}
  B2 -- true --> B2a[Run: roslynator (composite)]

  B --> C[Job: test]
  C --> C1[Run: dotnet/test (composite)]

  B --> D[Job: codeql]
  D --> D1[Run: dotnet/codeql (composite)]

  C & D --> E[Job: build]
  E --> E1[Run: dotnet/build (composite)]
  E1 --> F{app_version output set?}

  F --> G[Job: package]
  G --> G1{target == local-k8s or azure-webapp-container}
  G1 -- true --> G2[Run: dotnet/package (composite)]

  F --> H[Job: security]
  H --> H1{security-trivy?}
  H1 -- true --> H1a[Run: trivy scan (composite)]
  H --> H2{security-snyk?}
  H2 -- true --> H2a[Run: snyk scan (composite)]

  E & H --> I[Job: deploy]
  I --> I1{target == local-k8s}
  I1 -- true --> I2[Run: deploy/local-k8s-helm (composite)]

  style B fill:#f9f,stroke:#333,stroke-width:1px
  style C fill:#bbf,stroke:#333,stroke-width:1px
  style D fill:#bbf,stroke:#333,stroke-width:1px
  style E fill:#dfd,stroke:#333,stroke-width:1px
  style G fill:#ffd,stroke:#333,stroke-width:1px
  style H fill:#fcc,stroke:#333,stroke-width:1px
  style I fill:#cfc,stroke:#333,stroke-width:1px
```
