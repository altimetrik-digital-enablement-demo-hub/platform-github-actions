# .Net Composite Actions

Actions specifict to .Net platform used for building, linting, testing, security scanning and deployment to various platforms.

By default, all actions are using .Net version 9.0.300.

## Language filters

### csharp language

To use `csharp` actions in [Workflows](../../workflows/dev-csharp.yaml)

1. Set `inputs.language: csharp` 
2. Use `if: ${{ inputs.language == 'csharp' }}` condition to seelct `csharp` actions.

## Composite Actions List

### Linters

It is assumed that linters are installed as NuGet packages to the curent project, `inputs.restore: true` and they will be restored in the project with `dotnet tool restore`.

If `inputs.restore: false`, they will be installed globally as a tool before linting the project files.

#### csharp linters

  1. [csharpier](./lint/csharpier/action.yml)
  2. [roslynator](./lint/roslynator/action.yml)

### Build

The [build action](./build/action.yml) performs the following steps:

1. Sets-up dotnet environment with the default version set to `9.0.300`.
2. Installs dependencies.
3. Uses [versionize](https://github.com/versionize/versionize) to create a new GitHub Release based on [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#summary) format of commit messages.

  A new release is not created in case of insignificant commits which don't require the increment of the Major, Minor or Patch value.

Outputs:

  1. app_version - The new SemVer value of the incremented version. Empty string in case the version was not incremented.

### Test

Executes xUnit tests and creates a summary coverage report.

### CodeQL

A static code scanning for vulnerabiligies. It produces a summar report.

### Package

Build docker image and publish it to a registry. The default registry is `ghcr.io`. It uses `docker/metadata-action` action to generate the image tags based on version value geneated by the build job and the metadata collected from the GitHub repository.

The package job creates a sumamry report.

### Security Scan

Vulnerability scan of the docker image.

  1. [Snyk](./security-scan/snyk/action.yml)
  2. [Trivy](./security-scan/trivy/action.yml)

The security job creates a summary report.


### Deploy

Deploys the built artifact to a target platform.

1. local-k8s-helm - Deploys a container image to a local k8s cluster using Helm. A local [GitHub Runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners) is required for this action to work.
    - Select this target by setting `inputs.target: 'local-k8s'`

2. Azure App Web Sercices - Deploys application binary artifacts to [Azure App Web Services](https://azure.microsoft.com/en-us/products/app-service/web) platform. 
  Store Azure App [publish profile](https://learn.microsoft.com/en-us/visualstudio/azure/how-to-get-publish-profile-from-azure-app-service?view=vs-2022) as a repository secret. 
  
    - Pass the profile value through `inputs.azure_webapp_publish_profile`.
    - Select this target by setting `inputs.target: 'azure-webapp-svc'`
