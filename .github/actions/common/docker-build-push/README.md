# Docker Publish to GHCR

This GitHub Action builds and pushes a Docker image to the any container registry but defaults to [GitHub Container Registry (GHCR)](https://ghcr.io).

## Description

This action:
- Checks out the source code
- Logs in to GHCR using a provided GitHub token
- Normalizes the repository name to lowercase (required for GHCR)
- Builds the Docker image using metadata
- Tags it with both a custom version and `latest`
- Pushes it to `ghcr.io`

## Usage

```yaml
uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/actions/common/docker-build-push@main
with:
  version: '1.0.0'
  token: ${{ secrets.GITHUB_TOKEN }}
```

## Inputs

| Input Name | Description                                    | Purpose                                 | Required |
|------------|------------------------------------------------|-----------------------------------------|----------|
| `version`  | Version of the Docker image to build and push  | Tag the image for versioned deployments | ✅ Yes   |
| `token`    | GitHub token for authentication to GHCR        | Authenticate and push image to GHCR     | ✅ Yes   |

## Example Workflow

```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [main]

jobs:
  docker:
    runs-on: ubuntu-latest
    steps:
      - uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/actions/common/docker-build-push@main
        with:
          version: '1.0.0'
          token: ${{ secrets.GITHUB_TOKEN }}
```

## Notes

- The image will be published to:  
  `ghcr.io/<owner>/<repo>:<version>`  
  `ghcr.io/<owner>/<repo>:latest`
- The repository name is automatically converted to lowercase to comply with GHCR naming standards.

## Permissions

Ensure that your GitHub token has the following scopes:
- `write:packages`
- `read:packages`

