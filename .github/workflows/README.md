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
