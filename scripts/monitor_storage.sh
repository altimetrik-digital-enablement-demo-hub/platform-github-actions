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
