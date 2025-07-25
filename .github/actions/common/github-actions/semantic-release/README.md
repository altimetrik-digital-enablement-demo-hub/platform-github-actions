# Semantic Release Action

A composite GitHub Action that creates semantic GitHub releases with automatic version calculation and CHANGELOG generation based on conventional commits.

## Features

- **Automatic Version Calculation**: Analyzes commit messages to determine the next semantic version
- **Manual Version Override**: Allows specifying a custom version that overrides automatic calculation
- **Conventional Commits Support**: Recognizes standard commit message formats (feat, fix, major, etc.)
- **CHANGELOG Generation**: Automatically generates release notes with commit history
- **GitHub Release Creation**: Creates GitHub releases with proper tags and notes
- **Flexible Inputs**: Supports draft releases, prereleases, and custom release notes

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `token` | GitHub token for authentication | Yes | - |
| `version-bump` | Version bump type (auto, major, minor, patch) | No | `auto` |
| `manual-version` | Manual version (e.g., 1.2.3) - overrides version-bump | No | - |
| `release-notes` | Additional release notes to append to the CHANGELOG (max 512 chars) | No | - |
| `draft` | Create release as draft | No | `false` |
| `prerelease` | Create release as prerelease | No | `false` |

## Outputs

| Output | Description |
|--------|-------------|
| `tag` | The Docker tag for the release (e.g., v1.2.3, v1.2.3-draft, v1.2.3-prerelease) |
| `version` | The version number without 'v' prefix (e.g., 1.2.3) |

### Docker Tag Format

The `tag` output varies based on the release type:
- **Regular Release**: `v1.2.3`
- **Draft Release**: `v1.2.3-draft`
- **Prerelease**: `v1.2.3-prerelease`

## Version Bump Logic

### Auto Mode (Default)
The action analyzes commit messages since the last tag to determine the appropriate version bump:

- **Major**: Any commit with:
  - `BREAKING CHANGE:` in the commit body
  - `!` after type/scope (e.g., `feat!:`, `feat(api)!:`)
- **Minor**: Any commit containing "feat" keyword (unless major bump is needed)
- **Patch**: Any commit containing "fix", "docs", "style", "refactor", "perf", "test", "chore", "build", "ci", or "revert" keywords (unless major or minor bump is needed)

### Manual Mode
- **major**: Increments major version, resets minor and patch to 0
- **minor**: Increments minor version, resets patch to 0
- **patch**: Increments patch version

### Manual Version Override
When `manual-version` is provided, it overrides all automatic calculation and uses the specified version. The version must comply with semantic versioning format.

## Usage Examples

### Basic Usage (Auto Version)
```yaml
- uses: ./.github/actions/common/github-actions/semantic-release@v1
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
```

### Manual Version Bump
```yaml
- uses: ./.github/actions/common/github-actions/semantic-release@v1
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    version-bump: 'minor'
```

### Custom Version
```yaml
- uses: ./.github/actions/common/github-actions/semantic-release@v1
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    manual-version: '2.0.0'
```

### With Release Notes
```yaml
- uses: ./.github/actions/common/github-actions/semantic-release@v1
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    release-notes: |
      This release includes important security updates.
      Please upgrade as soon as possible.
```

### Draft Release
```yaml
- uses: ./.github/actions/common/github-actions/semantic-release@v1
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    draft: 'true'
```

### Prerelease
```yaml
- uses: ./.github/actions/common/github-actions/semantic-release@v1
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    prerelease: 'true'
```

### Draft Prerelease (Combined)
```yaml
- uses: ./.github/actions/common/github-actions/semantic-release@v1
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    draft: 'true'
    prerelease: 'true'
```

## Conventional Commits

The action recognizes the following conventional commit types:

- `feat`: New features (minor version bump)
- `fix`: Bug fixes (patch version bump)
- `docs`: Documentation changes (patch version bump)
- `style`: Code style changes (patch version bump)
- `refactor`: Code refactoring (patch version bump)
- `perf`: Performance improvements (patch version bump)
- `test`: Adding or updating tests (patch version bump)
- `chore`: Maintenance tasks (patch version bump)
- `build`: Build system changes (patch version bump)
- `ci`: CI/CD changes (patch version bump)
- `revert`: Reverting previous commits (patch version bump)

### Breaking Changes

Breaking changes are detected using:
- `BREAKING CHANGE:` in the commit body (major version bump)
- `!` after type/scope (e.g., `feat!:`, `feat(api)!:`) (major version bump)

## CHANGELOG Format

The generated CHANGELOG includes:

- Release version and date
- Git commit hash
- Previous version reference
- List of commits since last release
- Link to full changelog comparison
- Additional release notes (if provided)

Example:
```markdown
## v1.2.3

**Release Date**: January 15, 2024  
**Commit**: `abc1234`  
**Previous Version**: `v1.2.2`

### Changes

- feat: add new authentication feature (def5678)
- fix: resolve login issue (ghi9012)

**Full Changelog**: [v1.2.3 ... v1.2.2](https://github.com/org/repo/compare/v1.2.2...v1.2.3)

### Additional Notes

This release includes important security updates.
```

## Character Limits

- **Release Notes**: Maximum 512 characters
- **Total CHANGELOG**: Maximum 1024 characters (automatically truncated if exceeded)

## Error Handling

- If no valid semantic keywords are found in auto mode, the action skips the release
- Invalid manual versions are rejected with an error
- Invalid version-bump values result in an error
- Release notes exceeding 512 characters are rejected with an error
- The action gracefully handles repositories with no existing tags 