#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo "Missing scripts/.env. Create scripts/.env and fill project values."
    exit 1
fi

set -a
. "$SCRIPT_DIR/.env"
set +a

echo "Prepare project directory"
if [ "$PROJECT_NAME" != "AppName" ] && [ -d "$PROJECT_DIR/AppName" ]; then
    mv "$PROJECT_DIR/AppName" "$PROJECT_DIR/$PROJECT_NAME"
fi

echo "Prepare Generated directory"
mkdir -p "$PROJECT_DIR/$PROJECT_NAME/Resources/Generated"

echo "Run swiftgen"
"$SCRIPT_DIR/swiftgen/swiftgen.sh"

echo "Run xcodegen"
"$SCRIPT_DIR/xcodegen/xcodegen.sh"
