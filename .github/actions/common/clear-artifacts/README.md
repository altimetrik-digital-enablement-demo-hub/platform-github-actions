# Clear artifacts

Deletes all artifacts created by GitHub Workflows older than certain days. 

## Description

This action:

- Installs `jq` to be able to process GiHub API calls responses.
- Iterates over artifacts for a given repository and deletes those thaat are older than a given time range.

## Usage

Delete artifacts older than 5 days.

```yaml
uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/actions/common/clear-artifacts@v0
with:
  retention-days: 5
  token: ${{ secrets.GITHUB_TOKEN }}
```

## Inputs

| Input Name        | Description                                    | Purpose                                 | Required | Default |
|-------------------|------------------------------------------------|-----------------------------------------|----------|---------|
| `retention-days`  | Version of the Docker image to build and push  | Tag the image for versioned deployments | No       | 14 days | 
| `token`           | GitHub token for authentication to GHCR        | Authenticate and push image to GHCR     | Yes      |.        |

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
      - uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/actions/common/docker-build-push@v0
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

