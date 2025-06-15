# Contributing to `platform-github-actions`

Welcome to the centralized GitHub Actions library for our organization! This repository contains **reusable workflows** designed to standardize and simplify CI/CD pipelines across services and languages.

We value clean, consistent, and scalable automation—thank you for helping us improve it.

---

## 📦 What Belongs Here

This repository includes:

- Reusable workflows for common CI/CD stages (e.g., linting, testing, building)
- Language or platform-specific workflows (Node.js, Python, Java, etc.)
- Utility workflows (e.g., container publishing, deployment)
- Templates to help service teams onboard quickly

---

## 🛠️ Local Setup Instructions

To contribute or test workflows locally, follow these steps to set up this project on your machine:

### 1. Clone the Repository

```bash
git clone git@github.com:altimetrik-digital-enablement-demo-hub/platform-github-actions.git
cd platform-github-actions
```

---

### 2. Install Prerequisites

Ensure you have the following tools installed:

- **[Git](https://git-scm.com/)**


## 🧪 Setting Up GitHub Actions Runner Locally

To setup github action runner locally:

### Step-by-step Setup

1.  On macOS:  
     ```bash
     # Create a folder
      $ mkdir actions-runner && cd actions-runner
      # Download the latest runner package
      $ curl -o actions-runner-osx-x64-2.325.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.325.0/actions-runner-osx-x64-2.325.0.tar.gz
      # Extract the installer
      $ tar xzf ./actions-runner-osx-x64-2.325.0.tar.gz
      # Create the runner and start the configuration experience
      $ ./config.sh --url ${{ repo_url }}$ --token ${{ github_token}}
      # Last step, run it!
      $ ./run.sh
     ```
2.  On Windows:
     ```bash
     # Create a folder under the drive root
      $ mkdir actions-runner; cd actions-runner
      # Download the latest runner package
      $ Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.325.0/actions-runner-win-x64-2.325.0.zip -OutFile actions-runner-win-x64-2.325.0.zip
      # Extract the installer
      $ Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64-2.325.0.zip", "$PWD")
      # Create the runner and start the configuration experience
      $ ./config.cmd --url ${{ repo_url }} --token ${{ github_token }}
      # Run it!
      $ ./run.cmd
     ```

---

## 🛠 Workflow Requirements

All workflows **must**:

1. Use `on: workflow_call` to remain reusable.
2. Accept well-structured inputs:
   - Clear, concise naming
   - Reasonable default values
   - Descriptive documentation (via `README.md` or inline)
3. Follow naming conventions:
   - Examples: `test-node.yml`, `lint-python.yml`, `build-java.yml`
4. Include internal comments for any non-obvious logic
5. Never hardcode secrets — always use `secrets` as input parameters

---

## 🚀 Code Propagation Workflow

To roll out changes that other repositories can use:

1. **Create a feature branch**:
   ```bash
   git checkout -b feat/<feature-name>
   ```

2. **Make your changes**, then test them:
   - Use a sandbox repo to consume the workflow
   - Optionally simulate with [`act`](https://github.com/nektos/act)

3. **Commit using [Conventional Commits](https://www.conventionalcommits.org/)**:
   ```bash
   git commit -m "feat(node): add new linting workflow"
   ```

4. **Open a Pull Request (PR)** to the `main` branch and request a review.

5. **After approval and merge**, create a new **Git tag** to version your change:
   ```bash
   git tag v1.2.0
   git push origin v1.2.0
   ```

6. **Consumers** can update their reusable workflows by referencing the new tag in their `uses:` path:
   ```yaml
   uses: your-org/platform-github-actions/.github/workflows/test-node.yml@v1.2.0
   ```

---


## ✅ Review Checklist

Ensure every PR:

- Uses `workflow_call`
- Follows naming conventions and folder structure
- Has inputs that are typed, documented, and have defaults
- Includes meaningful inline comments
- Does **not** contain secrets or environment-specific values
- Is reusable across services

---

## 🧹 Linting and Validation

Before pushing:

```bash
yamllint .github/workflows/
```

---

## 🔐 Security Guidelines

- 🔒 **No secrets in code**. Always use:
  - `secrets.MY_SECRET` as input
  - GitHub Environments or repo-level secrets

- ⚠️ Avoid referencing privileged infrastructure in reusable workflows

---

## 🤝 Collaboration & Support

Need help?  
📬 Ping us in the `#platform-github-actions` Slack channel  
👥 Tag a `CODEOWNER` in your PR for a review

---

Let’s make CI/CD **fast**, **safe**, and **delightful** — for everyone.

Thanks for contributing! 💙
