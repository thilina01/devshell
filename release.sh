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
IFS='.' read -r MAJOR MINOR PATCH <<<"${LATEST_VERSION#v}"

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
git push origin "$NEW_VERSION"

echo "Release $NEW_VERSION completed successfully!"
