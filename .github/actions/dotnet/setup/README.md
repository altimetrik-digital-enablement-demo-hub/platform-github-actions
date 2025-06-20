# .Net setup action

Sets the .Net environment for a given project and restores project dependencies. 
It fetches repo to a given depth and retrieves tags by default.

## Inputs

| Name                   | Default   | Required | Description          |
| :---                   | :----     | :------: | :----                |
| dotnet-version         | 9.0.300   | no       | .Net version used to build, test and package the application |
| git-fetch-depth        | 1         | no       | The depth of the git fetch |
| git-fetch-tags         | true      | no       | Whether to fetch tags from the repository |
