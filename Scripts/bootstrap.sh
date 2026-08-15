#!/bin/sh

set -e

cd "$(dirname "$0")"

if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is required. Install it from https://brew.sh and run this script again."
    exit 1
fi

if [ -f ../Brewfile ]; then
    echo "Install command line tools from Brewfile"
    brew bundle --file=../Brewfile
fi

if command -v bundle >/dev/null 2>&1; then
    echo "Install Ruby dependencies"
    (cd .. && bundle install)
else
    echo "warning: Bundler is not installed. Skipping Ruby dependencies."
fi

if [ ! -f .env ]; then
    echo "Missing scripts/.env. Create scripts/.env and fill project values."
    exit 1
fi

set -a
. ./.env
set +a

printf "Have you configured scripts/.env? [y/N] "
read answer
case "$answer" in
    [yY]|[yY][eE][sS])
        ;;
    *)
        echo "Please fill scripts/.env and run this script again."
        exit 1
        ;;
esac

./generate.sh

echo "All set up. Opening ${PROJECT_NAME}.xcodeproj in Xcode."
open "../${PROJECT_NAME}.xcodeproj"
