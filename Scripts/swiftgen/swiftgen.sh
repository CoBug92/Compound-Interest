#!/bin/sh

set -e

export PATH="$PATH:/opt/homebrew/bin"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if [ -f "$PROJECT_ROOT/scripts/.env" ]; then
    . "$PROJECT_ROOT/scripts/.env"
fi

if command -v swiftgen >/dev/null 2>&1; then
    swiftgen config run --config "$SCRIPT_DIR/swiftgen.yml"
else
    echo "warning: SwiftGen not installed, download it from https://github.com/SwiftGen/SwiftGen"
    exit 1
fi
