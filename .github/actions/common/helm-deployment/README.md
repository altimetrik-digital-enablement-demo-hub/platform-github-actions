# Deploy with Helm

This GitHub Action builds and deploys a Kubernetes application using Helm.  
It is designed for CI/CD pipelines that need to install or upgrade Helm charts in Kubernetes clusters.

## Description

This action:
- Sets up `kubectl` and `helm` CLI tools
- Optionally decodes and uses a base64-encoded kubeconfig
- Installs or upgrades a Helm chart in a target Kubernetes namespace
- Sets the image repository and tag for deployment

## Usage

```yaml
uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/actions/common/helm-deployment@main
with:
  app-name: 'my-app'
  chart-path: './charts/my-app'
  repository: 'ghcr.io/my-org/my-app'
  tag: '1.0.0'
  kubeconfig: ${{ secrets.KUBECONFIG }}
  namespace: 'production'
```

## Inputs

| Input Name   | Description                                              | Purpose                                                  | Required | Default             |
|--------------|----------------------------------------------------------|----------------------------------------------------------|----------|---------------------|
| `app-name`   | Name of the application to deploy                        | Sets the Helm release name                               | ✅ Yes   | `react-app`         |
| `kubeconfig` | Base64-encoded kubeconfig to access the cluster          | Optional override of default cluster credentials         | ❌ No    | —                   |
| `chart-path` | Path to the Helm chart                                   | Specifies the chart directory                            | ✅ Yes   | `./charts/react-app`|
| `namespace`  | Kubernetes namespace                                     | Specifies where to deploy the application                | ❌ No    | `default`           |
| `repository` | Docker image repository (e.g., ghcr.io/org/app)         | Sets the image repository used in the Helm values        | ✅ Yes   | `latest`            |
| `tag`        | Docker image tag                                         | Defines the image version used in the Helm values        | ✅ Yes   | `latest`            |

## 🛠️ Example Workflow

```yaml
name: Deploy to Kubernetes

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Deploy via Helm
        uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/actions/common/helm-deployment@main
        with:
          app-name: 'react-app'
          chart-path: './charts/react-app'
          repository: 'ghcr.io/my-org/react-app'
          tag: '1.0.0'
          kubeconfig: ${{ secrets.KUBECONFIG }}
          namespace: 'production'
```

## Notes

- If `kubeconfig` is provided, ensure it is securely stored in GitHub Secrets as a base64-encoded string.
- The Helm chart must support `image.repository` and `image.tag` as values.