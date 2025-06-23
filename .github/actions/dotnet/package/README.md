# Package action

Build the docker image using provided Dockerfile and push it to a container registry. 
Package action is using `docker/metadata-action` action to extract git tags and metadata from the GitHub repository that could be used to create additional image tags and labels.

## Inputs

| Name          | Default | Required | Description          |
| :---          | :----   | :------: | :----                |
| app-name      |         | yes      | Application name     |
| language      | csharp  | no       | Programming language |
| context       | .       | no       | Context for docker build |
| docker-file   | ./Dockerfile  | no       | ath to the Dockerfile |
| image-tag     | latest  | no       | Tag for the Docker image |
| registry      | ghcr.io | no       | Container registry to push the image to|
| push          | true    | no       | Context for docker build |
| token         |         | yes       | A Github API token with permissions to create releases and push changes |
