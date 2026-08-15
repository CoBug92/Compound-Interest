#!/bin/sh

export PATH="/opt/homebrew/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_PATH="$SCRIPT_DIR/.swiftlint.yml"

if [ -f "$PROJECT_ROOT/scripts/.env" ]; then
    set -a
    . "$PROJECT_ROOT/scripts/.env"
    set +a
fi

PROJECT_NAME="${PROJECT_NAME:-AppName}"
LINT_PATH="$PROJECT_ROOT/$PROJECT_NAME"

if [ ! -d "$LINT_PATH" ] && [ -d "$PROJECT_ROOT/AppName" ]; then
    LINT_PATH="$PROJECT_ROOT/AppName"
fi

if which swiftlint >/dev/null; then
    cd "$PROJECT_ROOT" || exit 1
    swiftlint lint --config "$CONFIG_PATH" --no-cache "$LINT_PATH"
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
    exit 1
fi
