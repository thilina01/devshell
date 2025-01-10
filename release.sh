#!/usr/bin/env bash

# Set image repository
REPO="thilina01/devshell"

# Fetch the latest version from Git tags
LATEST_VERSION=$(git describe --tags $(git rev-list --tags --max-count=1) 2>/dev/null)

# Default to 0.0.0 if no tags exist
if [ -z "$LATEST_VERSION" ]; then
  LATEST_VERSION="0.0.0"
fi

# Parse the version components
IFS='.' read -r MAJOR MINOR PATCH <<<"$LATEST_VERSION"

# Determine the release type (major, minor, patch)
if [ "$1" == "major" ]; then
  ((MAJOR++))
  MINOR=0
  PATCH=0
elif [ "$1" == "minor" ]; then
  ((MINOR++))
  PATCH=0
else
  # Default to patch release
  ((PATCH++))
fi

# Create the new version
NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo "Releasing new version: $NEW_VERSION"

# Ensure the new tag doesn't already exist
if git ls-remote --tags origin | grep -q "refs/tags/$NEW_VERSION"; then
  echo "Error: Tag $NEW_VERSION already exists in the remote repository. Aborting."
  exit 1
fi

# Build and tag the images
docker build --target nano -t "$REPO:nano" -t "$REPO:$NEW_VERSION-nano" .
docker build -t "$REPO:latest" -t "$REPO:$NEW_VERSION" .

# Push the images to the registry
docker push "$REPO:latest"
docker push "$REPO:$NEW_VERSION"
docker push "$REPO:nano"
docker push "$REPO:$NEW_VERSION-nano"

# Tag the release in Git
git tag -a "$NEW_VERSION" -m "Release $NEW_VERSION"

# Push the tag to GitHub
if [ -n "$GITHUB_TOKEN" ]; then
  git push https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git "$NEW_VERSION"
elif [ -n "$PAT_TOKEN" ]; then
  git push https://x-access-token:${PAT_TOKEN}@github.com/${GITHUB_REPOSITORY}.git "$NEW_VERSION"
else
  echo "Error: No authentication token found. Set GITHUB_TOKEN or PAT_TOKEN."
  exit 1
fi

# Generate release notes based on commit messages
if [ "$LATEST_VERSION" != "0.0.0" ]; then
  CHANGELOG=$(git log "$LATEST_VERSION"..HEAD --pretty=format:"- %s (%h)")
else
  # Include all commits if no previous tag exists
  CHANGELOG=$(git log --pretty=format:"- %s (%h)")
fi

# Create a release using GitHub API
if [ -n "$GITHUB_TOKEN" ]; then
  curl -s -X POST "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases" \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "{
      \"tag_name\": \"$NEW_VERSION\",
      \"name\": \"Release $NEW_VERSION\",
      \"body\": \"## Changes\\n$CHANGELOG\\n\\n## Docker Images\\n- \`$REPO:latest\`\\n- \`$REPO:$NEW_VERSION\`\\n- \`$REPO:nano\`\\n- \`$REPO:$NEW_VERSION-nano\`\",
      \"draft\": false,
      \"prerelease\": false
    }"
else
  echo "Error: GITHUB_TOKEN is not set. Skipping GitHub release creation."
fi

echo "Release $NEW_VERSION completed successfully!"
