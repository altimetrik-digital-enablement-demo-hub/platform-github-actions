# Deployment to local k8s cluster with Helm

Deploy to local Kubernetes cluster with Helm and GitHub local runner.


## Inputs

| Name          | Default   | Required | Description          |
| :---          | :----     | :------: | :----                |
| release-name  |           | yes      | Helm release name    |
| namespace     | default   | no       | Kubernetes namespace to deploy to |
| registry      | ghcr.io   | no       | Docker registry storing the application image |
| image-name    |           | yes      | Docker image name |
| image-tag     |           | yes      | Docker image tag |
| chart         | app       | no       | Helm chart file system path | 
| helm-version  | helm3     | no       | Helm version to use: helm or helm3. Defaults to helm3 | 
