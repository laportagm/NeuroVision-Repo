#!/bin/bash
# Simple progress updater
# Usage: ./update_progress.sh "Task name" "status"

TASK=$1
STATUS=$2

if [ "$STATUS" = "done" ]; then
    sed -i '' "s/⬜ $TASK/✅ $TASK/g" docs/status/PROJECT_PROGRESS.md
elif [ "$STATUS" = "working" ]; then
    sed -i '' "s/⬜ $TASK/🟨 $TASK/g" docs/status/PROJECT_PROGRESS.md
fi

echo "Updated: $TASK -> $STATUS"
