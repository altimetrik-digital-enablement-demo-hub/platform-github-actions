# Trivy image scan

Trivy image vulnerabilities scan with `aquasecurity/trivy-action` GitHub Action. The action creates a summary report.

## Inputs

| Name          | Default | Required | Description          |
| :---          | :----   | :------: | :----                |
| registry      | ghcr.io | no       | Container registry to push the image to|
| image-name    |         | yes      | Docker image name     |
| image-tag     |         | yes      | Docker image tag |
| token         |         | yes       | A Github API token with permissions to create releases and push changes |
| severity      | CRITICAL,HIGH  | no | Comma-separated list of severities to include in the scan (e.g., CRITICAL,HIGH,MEDIUM,LOW) |
