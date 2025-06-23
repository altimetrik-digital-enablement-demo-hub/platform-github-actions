# Roslynator linter

Lint csharp code with roslynator.

## Inputs

| Name            | Default   | Required | Description          |
| :---            | :----     | :------: | :----                |
| app-name        |           | yes      | Application name     |
| dotnet-version  | 9.0.300   | no       | .Net version used to build, test and package the application |
| restore         | true      | no       | If true, restore roslynator tool from the project configuration. Otherwise, install it as a global tpol  |
