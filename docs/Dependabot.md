
# 🔧 Setting Up Dependabot for Private Repositories

This guide walks you through setting up GitHub Dependabot in a way that works for private repositories and supports authenticated access.

---

## ✅ Prerequisites

1. **GitHub repository** (must exist).
2. **Personal Access Token (PAT)** with the correct scopes.
3. **.github/dependabot.yml** configuration file.

---

## Create a GitHub PAT (Personal Access Token)

1. Go to: [https://github.com/settings/tokens](https://github.com/settings/tokens)
2. Click **"Fine-grained tokens"** and then click on **"Create new token"**
3. Select **Repository Access**: `All repositories`
4. **Select Permission**:
   - ✅ `Actions` (Read and Write)
   -  ✅ `Contents` (Read and Write)
   -  ✅ `Dependabot secrets` (Read and Write)
   -  ✅ `Pull requests` (Read and Write)
   -  ✅ `Secrets` (Read Only)
   -  ✅ `Workflows` (Read and Write)
5. Save the generated token securely (you won’t see it again).

---

## Add the Token as a GitHub Secret

In the repository that uses Dependabot:

1. Go to **Settings > Secrets and variables > Actions**
2. Click **“New repository secret”**
3. Add:
   - **Name**: `GHCR_PAT`
   - **Value**: *your personal access token*

> ⚠️ The user who owns the token **must have at least read access** to all private repositories Dependabot will access.

---

## 3⃣ Add or Update `dependabot.yml`

Place the following file in `.github/dependabot.yml` in your repo:

```yaml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/" # or "/.github/workflows" if that's where your workflows are
    schedule:
      interval: "daily"
    open-pull-requests-limit: 5
    registries:
      - github-actions-private

registries:
  github-actions-private:
    type: "git"
    url: "https://github.com"
    username: "x-access-token"
    password: "${{ secrets.GHCR_PAT }}"
```

---
