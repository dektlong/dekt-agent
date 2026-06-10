#!/usr/bin/env bash
#
# restart-apps.sh — restart every app in the dekt-mcps and dekt-agents spaces.
#
# Requires the `cf` CLI and an active login (`cf login`). The current org/space
# target is saved and restored when the script finishes.
#
# Usage:
#   ./restart-apps.sh                 # restart all apps in both spaces
#   ORG=my-org ./restart-apps.sh      # override the org (default: dekt)
#   SPACES="dekt-mcps" ./restart-apps.sh   # override the space list

set -euo pipefail

ORG="${ORG:-dekt}"
SPACES="${SPACES:-dekt-mcps dekt-agents}"

# --- preflight ---------------------------------------------------------------
command -v cf >/dev/null 2>&1 || { echo "error: cf CLI not found on PATH" >&2; exit 1; }
cf target >/dev/null 2>&1 || { echo "error: not logged in — run 'cf login' first" >&2; exit 1; }

# Remember the current target so we can restore it at the end.
ORIG_TARGET="$(cf target 2>/dev/null || true)"
ORIG_SPACE="$(printf '%s\n' "$ORIG_TARGET" | awk -F': *' '/^[Ss]pace:/ {print $2}' | tr -d ' ')"

restore_target() {
  if [[ -n "${ORIG_SPACE:-}" ]]; then
    cf target -o "$ORG" -s "$ORIG_SPACE" >/dev/null 2>&1 || true
  fi
}
trap restore_target EXIT

# --- main --------------------------------------------------------------------
failed=0

for space in $SPACES; do
  echo "============================================================"
  echo "Targeting org '$ORG' / space '$space'"
  echo "============================================================"

  if ! cf target -o "$ORG" -s "$space" >/dev/null; then
    echo "error: could not target org '$ORG' / space '$space' — skipping" >&2
    failed=1
    continue
  fi

  # `cf apps` prints a header/blank lines before the table; the first column
  # is the app name. Skip everything up to and including the "name" header row.
  apps="$(cf apps | awk 'NR>1 && found {print $1} /^name([[:space:]]|$)/ {found=1}')"

  if [[ -z "$apps" ]]; then
    echo "  (no apps found in '$space')"
    continue
  fi

  while IFS= read -r app; do
    [[ -z "$app" ]] && continue
    echo "  → restarting '$app'..."
    if cf restart "$app" >/dev/null; then
      echo "    ✓ restarted '$app'"
    else
      echo "    ✗ failed to restart '$app'" >&2
      failed=1
    fi
  done <<< "$apps"
done

echo "============================================================"
if [[ "$failed" -eq 0 ]]; then
  echo "Done — all apps restarted successfully."
else
  echo "Done — one or more apps failed to restart (see errors above)."
fi
exit "$failed"