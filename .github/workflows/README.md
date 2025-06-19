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

### csharp-build.yml

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

### csharp-deploy.yml

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
