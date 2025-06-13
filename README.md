# Platform GitHub Actions Library

This repository contains **reusable GitHub Actions workflows** that standardize CI/CD pipelines across our organization. These workflows are centrally maintained by the Platform Engineering team and are meant to be consumed via `workflow_call` from individual service repositories.


## Purpose

This library aims to:

- Centralize reusable workflows for consistent CI/CD pipelines.
- Reduce duplicated logic across services.
- Enforce security best practices (e.g., scanning, token usage).
- Enable faster onboarding and reliable deployments.
- Encourage modular and testable GitHub Actions design.

## Repository Structure

```plaintext
.github/
├── actions/         # Reusable custom actions
└── workflows/       # Reusable workflow templates
    ├── common/      # Common CI/CD stages
    │   ├── codeql.yml
    │   ├── docker-build-publish.yml
    │   ├── git-package.yml
    │   ├── git-tag-generation.yml
    │   ├── github-dashboard.yml
    │   ├── grype-scan.yml
    │   ├── trivy-scan.yml
    │   ├── helm-deployment.yml
    │   └── ...
    └── node/        # Node.js-specific workflows
        ├── build.yml
        ├── lint.yml
        ├── setup.yml
        └── ...
```

# What’s Included

| Location                      | Purpose                                                  |
|------------------------------|----------------------------------------------------------|
| `.github/actions/common/`    | Shared, language-agnostic actions (scans, packaging, tagging, deployment) |
| `.github/actions/node/`      | Node.js-specific actions only                            |
| `.github/workflows/`         | Reusable workflows combining multiple actions using `workflow_call` |

---

## How to Use

- All reusable workflows live under the `.github/workflows/` folder.
- These workflows use `workflow_call` and can be referenced in service repositories via:
- You can visit [reference section](./.github/workflows/README.md) to understand complete setup.

```yaml
jobs:
  use-dev-pipeline:
    uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/workflows/dev-node.yml@<ref>
    with:
      node-version: '20'
      lint-command: 'npm run lint'
      ...
```

## Action Format

Each custom action must include:

- A `README.md` (_optional but strongly recommended_)
- An `action.yml` file with:
  - Inputs clearly described with types, defaults, and required flags
  - `runs` section clearly defined (`composite` or `docker`)
  - Descriptive, minimal, and reusable logic

---

## Workflow Format

Reusable workflows should follow a stage-based format:

```yaml
jobs:
  lint:
    ...
  build:
    needs: lint
    ...
  test:
    needs: lint
    ...
  security:
    needs: build
    ...
  deploy:
    needs: security
    ...
```

- Use `needs:` to enforce job dependencies
- Keep environment setup (e.g., Node version) as shared `inputs`
- Follow the CI/CD stages described in the **#Stages** section

---

## Naming Conventions

- ✅ Use **kebab-case** for file and folder names:  
  _e.g., `docker-build-push.yml`, `jest-unit-test/`_

- ✅ Prefix actions with their domain for clarity:  
  _e.g., `node/lint`, `common/grype-scan`_

- ✅ Workflows should be named by use case or language:  
  _e.g., `dev-node.yml`, `release-java.yml`_

---


## Security Standards

- ❌ Never hardcode tokens or secrets  
- ✅ Use GitHub-provided secrets (`GITHUB_TOKEN`) or GitHub Environments  
- ✅ Only allow deployment actions if appropriate permissions and checks are in place  

---


## Documentation

Each new addition must include:

- A one-liner description in the `README.md` table
- Inputs documented (in table format if possible)
- Example usage (for both actions and workflows)

---


## Testing & Validation

Before merging:

- Check for expected input/output behavior
- Validate YAML syntax using GitHub Actions

---