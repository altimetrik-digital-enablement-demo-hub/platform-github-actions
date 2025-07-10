
# 🔧 Setting Up Dependabot for Private Repositories

This guide walks you through setting up GitHub Dependabot in a way that works for private repositories and supports authenticated access.

---

## ✅ Prerequisites

1. **GitHub repository** (must exist).
2. Properly configured Dependabot access settings.
3. **.github/dependabot.yml** configuration file.

---

## 🔐 Configure Dependabot Access to Private Repositories

1. Go to: [https://github.com/your-organization/settings/security_analysis](https://github.com/your-organization/settings/security_analysis)
2. Under **"Security"** and click on **"Global Settings"**
3. Scroll to the bottom of the page till section `Grant Dependabot access to repositories`.
4. For `Select Repositories` select all the repositories.

---


## Add or Update `dependabot.yml`

Place the following file in `.github/dependabot.yml` in your repo:

```yaml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/" # or "/.github/workflows" if that's where your workflows are
    schedule:
      interval: "daily"
    open-pull-requests-limit: 5
```

---
