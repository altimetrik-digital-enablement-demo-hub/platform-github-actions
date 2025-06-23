# Package Node Project

This GitHub Action packages a Node.js project using a custom packaging command (e.g., `npm pack`) and uploads the resulting artifact.  
It's useful in workflows for packaging and distributing Node.js applications or libraries.

## Description

This action:
- Runs a custom packaging command (default: `npm pack`)
- Captures the output package filename
- Uploads the packaged file as a GitHub Actions artifact

## Usage

```yaml
uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/actions/common/github-actions/git-package@main
with:
  package-command: 'npm pack'
  artifact-name: 'my-node-package'
  package-output-dir: '.'
```

## Inputs

| Input Name           | Description                                                                 | Purpose                                      | Required | Default           |
|----------------------|-----------------------------------------------------------------------------|----------------------------------------------|----------|-------------------|
| `package-command`    | Custom command to package the project (e.g., `npm pack`, `zip`, etc.)       | Executes this command to generate the package| ❌ No    | `npm pack`        |
| `artifact-name`      | Name to use for the uploaded artifact                                        | Identifies the artifact in GitHub UI         | ❌ No    | `package-artifact`|
| `package-output-dir` | Directory where the package is generated (relative to `working-directory`)  | Used as context for locating the package     | ❌ No    | `.`               |

## Example Workflow

```yaml
name: Package Node App

on:
  push:
    branches: [main]

jobs:
  package:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 18

      - name: Install Dependencies
        run: npm ci

      - uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/actions/common/github-actions/git-package@main
        with:
          package-command: 'npm pack'
          artifact-name: 'my-node-app'
```

## Notes

- The packaging command output must print the final package file path as the last line of output.
- Common use cases include `npm pack`, `zip -r`, or custom CLI packaging tools.