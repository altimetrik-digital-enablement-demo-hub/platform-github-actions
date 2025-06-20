# Deploy to Azure App Web Service

Deploy the binary artifact of the application to Azure App Web Service platform.

It assumes the application is created in Azure, `azure-webapp-name`, and the authentication is performed through `azure-webapp-publish-profile`.

## Inputs

| Name                          | Default  | Required | Description          |
| :---                          | :----    | :------: | :----                |
| azure-webapp-name             |          | yes      | Azure App Service name    |
| azure-webapp-package-path     |          | yes      | The path to your web app project, defaults to the repository root |
| azure-webapp-publish-profile  |           | yes  | The publish profile for the Azure Web App Service |
| dotnet-version                | 9.0.300   | no   | .Net version used to build, test and package the application |
