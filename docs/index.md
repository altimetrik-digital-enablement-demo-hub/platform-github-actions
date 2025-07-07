# platform-github-actions documentation

`platform-github-actions` is a centralized repository for managing reusable workflows and composite actions.

## Supported reusable workflows 

The following reusable workflows and actions are currently supported with the current version `v0`

1. Build
    - Lint
    - Unit tests
    - Security scan (static code)
        - CodeQL

    - Version - See versioning for non-prod releases.
    - Docker build and push
    - Docker scan
        - Grype
        - Trivy

2. Release

   Create a GitHub release with a new SemVer version value that is incremented based on Conventional Commits messages.
    - Version - See versioning for prod releases using SemVer format.
    - Docker build and push
    - Docker scan
        - Grype
        - Trivy
3. Deploy - Deploy to a target platform. By default, deploy to local Kubernetes cluster.


## Application repositories

A reference implentation of reusable workflows for various technologies:

1. Python - sample-python
2. Node - sample-node
3. CSharp - sample-csharp
4. Go - sample-go 
5. Java - sample-java


## Manage storage for GitHub Workflows

Effective management of storage in GitHub Workflows is essential for avoid failed Workflow runs.

See [./storage.md](./storage.md) for more details.
