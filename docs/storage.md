# Managing storage for GitHub Workflows


Working with private GitHub repositories and GitHub Actions requires careful management of limits, especially concerning storage. Here's a breakdown of the points you raised:

## 1\. Limits Imposed on Private Repositories Affecting GitHub Workflows and Actions

GitHub Actions usage for private repositories is subject to specific quotas for both included minutes and storage, which vary based on your GitHub plan (Free, Pro, Team, Enterprise Cloud). Exceeding these quotas can lead to additional costs or blocked workflows if a payment method isn't on file or spending limits are hit.

**Key Limits Affecting GitHub Workflows and Actions:**

* **Storage for Artifacts and Logs:**
  * **Included Storage:** This is the primary limit that impacts your use case.
    * GitHub Free: 500 MB
    * GitHub Pro: 1 GB
    * GitHub Free for organizations: 500 MB
    * GitHub Team: 2 GB
    * GitHub Enterprise Cloud: 50 GB
  * **Artifact Retention:** By default, GitHub stores build logs and artifacts for 90 days. For private repositories, you can customize this retention period from 1 day to 400 days. While this doesn't directly affect the *current* storage limit, a longer retention means more artifacts accumulate, potentially pushing you over your monthly included storage.
* **GitHub Packages Storage:** If your workflows publish Docker images or other packages to GitHub Packages, this storage also counts towards your overall GitHub storage limits.
* **Workflow Execution Limits (Minutes):**
  * Each plan also has a monthly quota of free minutes for GitHub-hosted runners.
  * Linux runners consume minutes at a 1x rate, Windows at 2x, and macOS at 10x. While not directly storage, long-running workflows can contribute to higher minute consumption, which can indirectly lead to more artifacts and logs if not managed.
  * Individual job execution time is limited to 6 hours.
  * Workflow run time is limited to 35 days (includes execution and waiting).
* **Cache Storage:** You can set a total cache storage size for your repository up to the maximum allowed by your organization or enterprise policy. This is distinct from artifact storage but also contributes to overall storage consumption.

## 2\. Best Practices for Managing These Limits

**General Best Practices:**

* **Optimize Workflow Triggers:**
  * Use `paths-ignore` in your workflow triggers to prevent unnecessary runs for changes that don't affect your build or deploy, e.g., documentation updates.
  * Utilize `concurrency` with `cancel-in-progress: true` for frequently triggered workflows (like `push` or `pull_request` on development branches). This ensures only the latest run proceeds, canceling older, irrelevant runs and saving both minutes and potentially artifact storage.
* **Lean Docker Images:**
  * **Multi-stage builds:** This is crucial for creating smaller Docker images. Isolate build dependencies in earlier stages and only copy the necessary artifacts to the final image.
  * **.dockerignore:** Effectively use a `.dockerignore` file to exclude unnecessary files from your build context (e.g., `.git`, `node_modules`, documentation).
  * **Optimize Layer Caching:** Order Dockerfile instructions to leverage caching effectively. Copy stable files first, defer frequently changing files to later layers, and combine related commands into a single `RUN` instruction.
* **Efficient Artifact Management:**
  * **Upload Only Necessary Artifacts:** Carefully consider what artifacts truly need to be stored. Do you need build logs for every successful run, or just for failures? Do you need all intermediate build outputs, or just the final executable/package?
  * **Minimize Artifact Size:** If possible, compress artifacts before uploading them.
  * **Set Shorter Artifact Retention Periods:** For artifacts that are only needed for a short debugging window, set a custom, shorter retention period (e.g., 1-7 days) on the `upload-artifact` step or at the repository level. This will ensure they are automatically deleted sooner.
  * **Use Caching for Dependencies:** Use `actions/cache` for frequently used dependencies (e.g., `node_modules`, Maven repositories, NuGet packages). Caching reduces job execution time and can prevent redundant downloads, though the cache itself consumes storage.
  * **Distinguish Artifacts vs. Cache:** Understand the difference:
    * **Artifacts:** For saving files produced by a job to view *after* a workflow run (e.g., built binaries, test reports).
    * **Cache:** For reusing files that don't change often *between* jobs or workflow runs (e.g., package dependencies).

  **Example: Staying Below Storage Threshold for Artifacts and Docker Images**

Let's say you have a workflow that builds a Docker image and then uploads some test reports as artifacts.

```yaml

name: Build and Test

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build_and_test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Cache Docker layers
        uses: actions/cache@v4
        with:
          path: /tmp/.buildx-cache
          key: ${{ runner.os }}-buildx-${{ github.sha }}
          restore-keys: |
            ${{ runner.os }}-buildx-

      - name: Build Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          file: ./Dockerfile
          push: false # Set to true if pushing to a registry like GHCR
          tags: my-org/my-repo:latest
          cache-from: type=local,src=/tmp/.buildx-cache
          cache-to: type=local,dest=/tmp/.buildx-cache-new,mode=max

      # This step ensures that the cache is updated correctly for subsequent runs
      # Important: Only run on default branch or push to avoid cache conflicts
      - name: Move cache
        run: |
          rm -rf /tmp/.buildx-cache
          mv /tmp/.buildx-cache-new /tmp/.buildx-cache
        if: always() # Ensure this runs even if previous steps fail

      - name: Run tests
        run: |
          # Example: Run tests inside the built Docker image
          docker run my-org/my-repo:latest /app/run_tests.sh > test_results.log
          # Simulate creating a large report
          dd if=/dev/zero of=large_report.txt bs=1M count=10

      - name: Upload test results artifact
        uses: actions/upload-artifact@v4
        with:
          name: test-results
          path: test_results.log
          retention-days: 7 # Custom retention for this artifact to save space
      
      - name: Upload large report artifact (with shorter retention)
        uses: actions/upload-artifact@v4
        with:
          name: large-report
          path: large_report.txt
          retention-days: 1 # Only keep for 1 day, useful for quick debugging

```

**Explanation of storage management in the example:**

* **Docker Buildx with Caching:** The `docker/setup-buildx-action` and `docker/build-push-action` leverage Buildx's caching capabilities, which can significantly reduce build times and prevent re-downloading layers. The cache itself consumes storage.
* **`retention-days` for artifacts:** We explicitly set `retention-days` to a shorter period (e.g., 1 or 7 days) for artifacts that aren't needed long-term. This automatically cleans up old artifacts, preventing continuous storage growth.
* **`push: false` for Docker images (if not publishing):** If the image is only for testing within the workflow and not intended for deployment, avoid pushing it to a registry (like GitHub Container Registry) to save on Packages storage. If you do push, ensure you have a good tagging and cleanup strategy for your registry.

## 3\. Monitor Storage Utilization and Other Important Metrics

Monitoring is crucial for proactive management.

* **GitHub UI (Billing & Usage):**

  * **Organization/Account Settings -\> Billing & Plans -\> Usage:** This is the primary place to see your overall GitHub Actions usage, including storage (artifacts and packages) and minutes consumed. You can view summaries and detailed breakdowns.
  * **Repository Settings -\> Actions -\> General -\> Artifact and log retention:** You can see the default retention period set and modify it.
  * **Repository Settings -\> Actions -\> General -\> Cache size limit:** You can see and adjust the cache size limit for the repository.

* **GitHub Actions Metrics (Insights):**

  * **Organization Insights -\> Actions Usage Metrics:** Provides insights into how many minutes your workflows and jobs consume, helping you understand costs.
  * **Organization Insights -\> Actions Performance Metrics:** Focuses on efficiency (run times, queue times, failure rates) which can indirectly indicate where you might be consuming more resources.

* **GitHub API:** The GitHub API provides endpoints to programmatically retrieve billing information, workflow run details, artifact lists, and more. This is essential for building custom monitoring solutions.

  * `GET /repos/{owner}/{repo}/actions/artifacts`: List artifacts for a repository.
  * `GET /repos/{owner}/{repo}/actions/runs`: List workflow runs.
  * `GET /orgs/{org}/settings/billing/actions`: Get GitHub Actions billing for an organization.

  * **Custom Scripting:** As seen in search results, a custom script using GitHub CLI and `jq` can be very effective for getting a consolidated view of artifact and cache storage across repositories in an organization. This is especially useful since GitHub's UI doesn't provide a single "total storage" view for artifacts.

  * Example Script (modified from common examples for clarity):

  <!-- end list -->

    #!/bin/bash

    # Requires GitHub CLI (gh) and jq installed
    # Ensure you are authenticated with 'gh auth login'
    ORG_NAME="$1"
    if [ -z "$ORG_NAME" ]; then
      echo "Usage: $0 <organization_name>"
      exit 1
    fi

    echo "Monitoring GitHub Actions Storage for Organization: $ORG_NAME"
    echo "--------------------------------------------------"

    TOTAL_ARTIFACT_SIZE_BYTES=0
    TOTAL_CACHE_SIZE_BYTES=0

    # Get all repositories in the organization
    REPOS=$(gh api "orgs/$ORG_NAME/repos?per_page=100" --paginate -q '.[].name')

    for REPO in $REPOS; do
      echo "Processing repository: $ORG_NAME/$REPO"
      REPO_ARTIFACT_SIZE_BYTES=0
      REPO_CACHE_SIZE_BYTES=0

      # Get artifacts for the repository
      ARTIFACTS_RESPONSE=$(gh api "repos/$ORG_NAME/$REPO/actions/artifacts?per_page=100" --paginate 2>/dev/null)
      ARTIFACT_SIZES=$(echo "$ARTIFACTS_RESPONSE" | jq -r '.artifacts[].size_in_bytes // 0')

      for SIZE in $ARTIFACT_SIZES; do
        REPO_ARTIFACT_SIZE_BYTES=$((REPO_ARTIFACT_SIZE_BYTES + SIZE))
      done

      # Get cache for the repository (more complex, GitHub API doesn't directly expose total cache size easily)
      # You'd typically infer this from cache-related actions or by monitoring the 'Cache size limit' setting.
      # The `gh api` doesn't have a direct endpoint to list total cache utilization by repo.
      # The following is a placeholder for demonstrating where cache monitoring would fit if an API existed.
      # For practical purposes, you'd rely on the UI setting or approximations.
      
      # For a more accurate cache monitoring, you'd need to track individual cache entries and their sizes
      # via logs or by leveraging the GitHub Actions cache service internal workings.
      # For now, we'll just report what's available or set a placeholder.
      # Example: If you have a specific cache action, you might be able to get its size from logs.
      
      # Placeholder for cache size (replace with actual logic if possible)
      # Some articles suggest there's no direct API to sum up cache usage like artifacts.
      # You might need to check 'Repository-> Settings-> Actions-> General-> Cache size limit' manually or infer from cache key sizes.

      REPO_ARTIFACT_SIZE_MB=$(echo "scale=2; $REPO_ARTIFACT_SIZE_BYTES / (1024 * 1024)" | bc)
      REPO_CACHE_SIZE_MB=$(echo "scale=2; $REPO_CACHE_SIZE_BYTES / (1024 * 1024)" | bc) # Placeholder for now

      echo "  Total artifact size for $ORG_NAME/$REPO: ${REPO_ARTIFACT_SIZE_MB} MB"
      echo "  Total cache size for $ORG_NAME/$REPO: ${REPO_CACHE_SIZE_MB} MB (approx/placeholder)" # Update if better method found

      TOTAL_ARTIFACT_SIZE_BYTES=$((TOTAL_ARTIFACT_SIZE_BYTES + REPO_ARTIFACT_SIZE_BYTES))
      TOTAL_CACHE_SIZE_BYTES=$((TOTAL_CACHE_SIZE_BYTES + REPO_CACHE_SIZE_BYTES))
    done

    TOTAL_ARTIFACT_SIZE_GB=$(echo "scale=2; $TOTAL_ARTIFACT_SIZE_BYTES / (1024 * 1024 * 1024)" | bc)
    TOTAL_CACHE_SIZE_GB=$(echo "scale=2; $TOTAL_CACHE_SIZE_BYTES / (1024 * 1024 * 1024)" | bc)

    echo "--------------------------------------------------"
    echo "Overall Usage for $ORG_NAME:"
    echo "Total Artifact Storage: ${TOTAL_ARTIFACT_SIZE_GB} GB"
    echo "Total Cache Storage (approx/placeholder): ${TOTAL_CACHE_SIZE_GB} GB"
    echo "--------------------------------------------------"


  Save this as `monitor_storage.sh`, make it executable (`chmod +x monitor_storage.sh`), and run it with your organization name: `./monitor_storage.sh YourOrgName`.

## 4\. Solutions for Reducing Storage Utilization on Demand

Here's a multi-pronged solution combining changing action settings and an on-demand script:

**A. Proactive Measures (Action Settings):**

1. **Enforce Shorter Default Artifact Retention:**
      * **Repository Level:** Go to `Repository -> Settings -> Actions -> General`. Under "Artifact and log retention", set a shorter default (e.g., 7 days or 14 days) for all artifacts in that repository. This is the easiest way to prevent old artifacts from accumulating.
      * **Workflow Level:** For specific artifacts that are only needed for very short-term debugging (e.g., temporary build logs or intermediate files), override the repository default by adding `retention-days: 1` or `retention-days: 3` to the `actions/upload-artifact` step. This is shown in the example in section 2.
2. **Optimize Cache Usage:**
      * **Cache Invalidation Strategy:** Ensure your cache keys are granular enough to avoid caching stale dependencies but broad enough to get hits.
      * **Regular Cache Cleanup (Manual/Scheduled):** While GitHub actions don't have an automated cache cleanup outside of retention, you can sometimes manually delete caches through the UI or consider a scheduled workflow to clear specific, known large caches if they become problematic (though this might negate caching benefits).
3. **Docker Image Management (if using GitHub Packages):**
      * **Set Image Retention Policies:** For images published to GitHub Container Registry (GHCR), set up retention policies to automatically delete old or untagged images. You can do this through the GHCR settings in your repository or organization.
      * **Multi-stage builds:** As mentioned in best practices, this is critical for small image sizes.

**B. Reactive Solution (On-Demand Script for Artifact Cleanup):**

When a threshold is breached or proactively to free up space, an on-demand script is the most direct way to clean up artifacts.

**Solution: Automated Artifact Cleanup Script (using GitHub CLI)**

This script will list artifacts older than a specified number of days and then delete them. It can be run manually or as part of a scheduled GitHub Action.

```bash
#!/bin/bash

# Requires GitHub CLI (gh) and jq installed
# Ensure you are authenticated with 'gh auth login' with appropriate permissions (repo scope for delete)

OWNER="$1"      # Organization or user name
REPO="$2"       # Repository name
RETENTION_DAYS="$3" # Artifacts older than this will be deleted

if [ -z "$OWNER" ] || [ -z "$REPO" ] || [ -z "$RETENTION_DAYS" ]; then
  echo "Usage: $0 <owner> <repository> <retention_days>"
  echo "Example: $0 my-org my-project 7  (Deletes artifacts older than 7 days in my-org/my-project)"
  exit 1
fi

echo "Initiating artifact cleanup for $OWNER/$REPO. Deleting artifacts older than $RETENTION_DAYS days."
echo "----------------------------------------------------------------------------------"

# Calculate the cutoff date
CUTOFF_DATE=$(date -d "$RETENTION_DAYS days ago" +%s)

# Fetch all artifacts for the repository, paginating
ARTIFACTS=$(gh api "repos/$OWNER/$REPO/actions/artifacts?per_page=100" --paginate)

# Parse artifact IDs and created_at timestamps
echo "$ARTIFACTS" | jq -r '.artifacts[] | select(.expired == false) | "\(.id) \(.created_at)"' | while read -r ID CREATED_AT; do
  ARTIFACT_TIMESTAMP=$(date -d "$CREATED_AT" +%s)

  if (( ARTIFACT_TIMESTAMP < CUTOFF_DATE )); then
    echo "Deleting artifact ID: $ID (Created: $CREATED_AT)"
    gh api --method DELETE "repos/$OWNER/$REPO/actions/artifacts/$ID" --silent
    if [ $? -eq 0 ]; then
      echo "  Successfully deleted artifact ID: $ID"
    else
      echo "  Failed to delete artifact ID: $ID"
    fi
  else
    echo "Skipping artifact ID: $ID (Created: $CREATED_AT) - within retention period."
  fi
done

echo "----------------------------------------------------------------------------------"
echo "Artifact cleanup process completed."

```

**How to Use the Script:**

1. **Save:** Save the script as `cleanup_artifacts.sh`.

2. **Permissions:** Make it executable: `chmod +x cleanup_artifacts.sh`.

3. **Authentication:** Ensure your `gh` CLI is authenticated with a Personal Access Token (PAT) that has `repo` scope for read/delete permissions.

4. **Run Manually:**

    ```bash
    ./cleanup_artifacts.sh YourOrganizationName YourRepoName 30 
    ```

    (This will delete all artifacts in `YourOrganizationName/YourRepoName` older than 30 days.)

5. **Integrate into a GitHub Workflow (Scheduled or Manual Trigger):**

    You could create a workflow that runs this script on a schedule or on a `workflow_dispatch` event (manual trigger).

    ```yaml
    name: On-Demand Artifact Cleanup

    on:
      workflow_dispatch:
        inputs:
          repo_name:
            description: 'Repository name to clean (e.g., my-project)'
            required: true
          owner_name:
            description: 'Organization/User name (e.g., my-org)'
            required: true
          retention_days:
            description: 'Delete artifacts older than this many days'
            required: true
            default: '14' # Default to 14 days if not specified

    jobs:
      cleanup:
        runs-on: ubuntu-latest
        steps:
          - name: Checkout repository (optional, if script is in repo)
            uses: actions/checkout@v4

          - name: Install jq (if not on runner by default)
            run: sudo apt-get update && sudo apt-get install -y jq

          - name: Run artifact cleanup script
            env:
              GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }} # Or a PAT with repo scope
            run: |
              ./cleanup_artifacts.sh ${{ github.event.inputs.owner_name }} ${{ github.event.inputs.repo_name }} ${{ github.event.inputs.retention_days }}
            # If the script is not checked out, you'd put the script content directly here or download it.
    ```

    **Important Considerations for the Script:**

      * **`GITHUB_TOKEN` vs. PAT:** For `DELETE` operations, the default `GITHUB_TOKEN` often has limited permissions. You might need to generate a Personal Access Token (PAT) with `repo` scope and store it as a repository secret (e.g., `CLEANUP_PAT`) and use `GITHUB_TOKEN: ${{ secrets.CLEANUP_PAT }}`. Be extremely careful with PATs and their scopes.
      * **Error Handling:** Add more robust error handling and logging to the script for production use.
      * **Testing:** Test the script thoroughly on a non-critical repository before deploying it widely.

By combining proactive settings adjustments with reactive, on-demand cleanup scripts and consistent monitoring, your team can effectively manage GitHub Actions storage limits in private repositories.
