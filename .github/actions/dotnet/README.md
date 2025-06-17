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

