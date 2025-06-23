# .Net release action

It creates a GitHub release with [versionize](https://github.com/versionize/versionize) tool based on [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) conventions.

Versionize require downloading all GitHub history and tags in order to calculate the next version.

If the commits are insignificant, no new version and release is created, which results in skipping the GitHub Relese steps.

## Inputs

| Name                    | Default   | Required | Description          |
| :---                    | :----     | :------: | :----                |
| dotnet-version          | 9.0.300   | no       | .Net version used to build, test and package the application |
| git-fetch-depth         | 1         | no       | The depth of the git fetch |
| git-fetch-tags          | true      | no       | If yes, fetch tags from the repository |
| token                   |           | yes       | A Github API token with permissions to create releases and push changes |

## Outputs

| Name                    | Description  |
| :---                    | :----        |
| app-version             | The new version of the application as determined by Versionize. Empty string if version is not incremented |
