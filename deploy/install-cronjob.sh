#!/usr/bin/env bash

set -e

cd "$(dirname "$0")"
if [[ -f .env ]]; then
    source .env
fi

if [[ -z "$RELEASE_BRANCH" ]]; then
    echo "RELEASE_BRANCH env required"
    exit 1
fi

SCRIPT_DIR=$(pwd)
LOG_DIR="$SCRIPT_DIR/.logs"
RELEASE_NAME="deepvi-cdn-$RELEASE_BRANCH"
CRONJOB_FILE="/etc/cron.d/$RELEASE_NAME"

mkdir -p "$LOG_DIR"
echo "*/2 * * * * root /bin/bash $SCRIPT_DIR/cronjob.sh > $LOG_DIR/$RELEASE_NAME.log 2>&1" > "$CRONJOB_FILE"
service cron reload

echo "cronjob installed to ${CRONJOB_FILE} (branch=${RELEASE_BRANCH} name=${RELEASE_NAME})"
