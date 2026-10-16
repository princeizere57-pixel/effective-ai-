#!/usr/bin/env bash
set -euo pipefail

# Codespaces has no browser inside the container, so serve the app on port 4028
# and open it through the forwarded port.
ARGS=(-d web-server --web-port 4028 --web-hostname 0.0.0.0)
if [ -f env.json ]; then
  ARGS+=(--dart-define-from-file=env.json)
fi

flutter run "${ARGS[@]}"
