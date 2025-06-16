# Platform GitHub Actions Library

This repository contains **reusable GitHub Actions workflows** that standardize CI/CD pipelines across our organization. These workflows are centrally maintained by the Platform Engineering team and are meant to be consumed via `workflow_call` from individual service repositories.


## Goals

This library aims to:

- **Centralized Workflows and Actions management:** Ensure consistent standards and best practices are followed across numerous GitHub repositories.
- **Reduced duplication:** Eliminate the need for developers to rewrite common tasks repeatedly, saving time and reducing the risk of errors.
- **Enforce security best practices:** Build a more secure CI/CD pipeline by embedding security checks (static code analysis, dependency scanning, container scanning, etc) into your automated workflows, allowing for continuous monitoring, early detection and rapid response to potential threats.
- **Faster onboarding:** Enable new projects to quickly adopt CI/CD automation through using workflows tailored for their technology stacks, clear documentation, and reduced manual setup.
- **Reliable deployments:** Introduce changes consistently across various deployment environments.
- **Modular and testable design:** Add and test new features easily without disruping existing workflows and actions.

## Repository Structure

```plaintext
.github/
├── workflows/    # Reuseable templates
│    ├── node-build.yml   
│    ├── node-deploy.yml  
└── actions/       # Reusable custom actions
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
    ├── java/
    ├── python/
    ├── go
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
- These workflows use `workflow_call` and can be referenced in service repositories via: ` uses: altimetrik-digital-enablement-demo-hub/platform-github-actions/.github/workflows/dev-node-build.yml@v0.0.1` 
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

- A `README.md`
- An `action.yml` file with:
  - Inputs clearly described with types, defaults, and required flags
  - **Convention over Configuration:** Use as much as possible reasonable defaults for input parameters and make them optional. 
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

- Use `needs:` to define dependencies on other jobs
- Keep environment setup (e.g., Node version) as `parameterized inputs`

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
  - ✅ Allow (`GITHUB_TOKEN`) with read/write permissions for - `Actions`, `Contents`, `Deployments`, `Pages`, `Secrets` & `Workflows`

---

# Adding new Reusable Workflows and Actions
## Documentation

A new Reusable Workflow or Composite Action must include at least:

- A one-liner description in the `README.md` table
- Inputs documented (in table format if possible)
- Example usage (for both actions and workflows)

---


## Testing & Validation

Before merging:

- Lint YAML syntax of new Workflows and Actions.
- Create a test Workflow to test new Reusable Workflow and Composite Actions.
- Provide a link to test Workflow in the PR.
- Test deployments in local Kubernetes clusters using local GitHub Runners.

---