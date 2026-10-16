#!/usr/bin/env bash
set -euo pipefail

# Generate the web platform folder on first start (lib/ and pubspec.yaml are kept).
if [ ! -d web ]; then
  flutter create . --project-name learnspace --platforms web
fi

flutter pub get

echo ""
echo "Ready. Start the app with:  bash .devcontainer/run-web.sh"
