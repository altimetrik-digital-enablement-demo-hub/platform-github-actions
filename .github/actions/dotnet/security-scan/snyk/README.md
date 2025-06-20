# Snyk image scan

Snyk image vulnerabilities scan with `snyk/actions/docker` GitHub Action. The action creates a summary report.

## Inputs

| Name          | Default | Required | Description          |
| :---          | :----   | :------: | :----                |
| registry      | ghcr.io | no       | Container registry to push the image to|
| image-name    |         | yes      | Docker image name     |
| image-tag     |         | yes      | Docker image tag |
| docker-file   | ./Dockerfile | no | Path to the Dockerfile |
| token         |         | yes       | A Github API token with permissions to create releases and push changes |
