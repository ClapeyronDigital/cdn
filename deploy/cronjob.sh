#!/usr/bin/env bash

set -e

cd "$(dirname "$0")"
if [[ -f .env ]]; then
    source .env
fi

echo "$(date +%Y-%m-%d--%H:%M:%S)"

if [[ -z "$RELEASE_BRANCH" ]]; then
    echo "RELEASE_BRANCH env required"
    exit 1
fi

RELEASE_NAME="deepvi-cdn-$RELEASE_BRANCH"
REPO_ROOT=$(git rev-parse --show-toplevel)

LAST_COMMIT_FILE=".last-built-commit"
git checkout "$RELEASE_BRANCH"
git pull

CURRENT_COMMIT=$(git rev-parse HEAD)
LAST_COMMIT=$(cat "$LAST_COMMIT_FILE" 2> /dev/null || echo "nocommit")

echo "current=$CURRENT_COMMIT last=$LAST_COMMIT"

if [ "$CURRENT_COMMIT" != "$LAST_COMMIT" ]; then
    echo "pulled new commit"
    if [[ -n "$RELEASE_TARGET_PREFIX" ]]; then
        echo "syncing release target..."
        TARGET_DIR="$RELEASE_TARGET_PREFIX/$RELEASE_NAME"
        mkdir -p "$TARGET_DIR"
        git -C "$REPO_ROOT" ls-files -z --cached --others --exclude-standard ':!:.gitignore' ':!:deploy/**' \
            | rsync -a --delete --from0 --files-from=- "$REPO_ROOT/" "$TARGET_DIR/"
    fi
    echo "$CURRENT_COMMIT" > "$LAST_COMMIT_FILE"
fi
