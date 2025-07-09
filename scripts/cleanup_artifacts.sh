#!/bin/bash

# Requires GitHub CLI (gh) and jq installed
# Ensure you are authenticated with 'gh auth login' with appropriate permissions (repo scope for delete)

REPO="$1"       # Repository name
RETENTION_DAYS="${2:-5}" # Artifacts older than this will be deleted
OWNER="${3:-altimetrik-digital-enablement-demo-hub}"      # Organization or user name


if [ -z "$OWNER" ] || [ -z "$REPO" ] || [ -z "$RETENTION_DAYS" ]; then
cat <<EOF
  Usage: `basename $0` <repository> <retention_days> <owner>
    where:
      <repository>       - Name of the repository (e.g., sample-csharp)
      <retention_days>   - Number of days to retain artifacts (default: 5)
      <owner>            - GitHub organization or user name (default: altimetrik-digital-enablement-demo-hub)
    
    Examples: `basename $0` sample-csharp 7  (Deletes artifacts older than 7 days in altimetrik-digital-enablement-demo-hub/sample-csharp)
EOF
  exit 0
fi

echo "Initiating artifact cleanup for $OWNER/$REPO. Deleting artifacts older than $RETENTION_DAYS days."
echo "----------------------------------------------------------------------------------"

# Get the operating system name
OS=$(uname)
DATE_COMMAND="date" # Default to 'date' for Linux

if [[ "$OS" == "Darwin" ]]; then
    # Check if gdate is available on macOS (from coreutils)
    if command -v gdate &> /dev/null; then
        DATE_COMMAND="gdate"
    else
        echo "Error: GNU date (gdate) not found. Install it using `brew install coreutils`"
        exit 1
    fi
fi

if [[ "$OS" == "Darwin" ]]; then
    echo "Using macOS syntax."
    CUTOFF_DATE=$(date -v -${RETENTION_DAYS}d +%s)
elif [[ "$OS" == "Linux" ]]; then
    echo "Using Linux suntax."
    CUTOFF_DATE=$(date -d "$RETENTION_DAYS days ago" +%s)
else
    echo "Unknown OS; Using Linux suntax."
    CUTOFF_DATE=$(date -d "$RETENTION_DAYS days ago" +%s)
fi

# Calculate the cutoff date


# Fetch all artifacts for the repository, paginating
ARTIFACTS=$(gh api "repos/$OWNER/$REPO/actions/artifacts?per_page=100" --paginate)

# Parse artifact IDs and created_at timestamps
echo "$ARTIFACTS" | jq -r '.artifacts[] | select(.expired == false) | "\(.id) \(.created_at)"' | while read -r ID CREATED_AT; do
  echo "ID: $ID, Created At: $CREATED_AT"
  if [[ "$OS" == "Darwin" ]]; then
    echo "Using macOS syntax."
    ARTIFACT_TIMESTAMP=$($DATE_COMMAND -u -d "$CREATED_AT - $RETENTION_DAYS days" +"%s")
  elif [[ "$OS" == "Linux" ]]; then
    ARTIFACT_TIMESTAMP=$(date -d "${CREATED_AT}" +%s)  
  else
    ARTIFACT_TIMESTAMP=$(date -d "$CREATED_AT" +%s)
  fi



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
