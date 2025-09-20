#!/usr/bin/env bash
# build-knowledge-robust.sh (lean, robust root discovery)

set -euo pipefail

# Resolve script path, follow symlinks
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# 1) Env override, 2) git root, 3) walk-up until FRAMEWORK.md found
REPO_ROOT="${AP_REPO_ROOT:-}"
is_root() { [[ -f "$1/FRAMEWORK.md" ]]; }

if [[ -z "${REPO_ROOT}" ]]; then
  if command -v git >/dev/null 2>&1; then
    set +e; GIT_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null)"; set -e
    [[ -n "$GIT_ROOT" && -f "$GIT_ROOT/FRAMEWORK.md" ]] && REPO_ROOT="$GIT_ROOT"
  fi
fi
if [[ -z "${REPO_ROOT}" ]]; then
  CAND="$SCRIPT_DIR"
  while true; do
    if is_root "$CAND"; then REPO_ROOT="$CAND"; break; fi
    PARENT="$(dirname "$CAND")"; [[ "$PARENT" == "$CAND" ]] && break; CAND="$PARENT"
  done
fi
[[ -n "${REPO_ROOT}" ]] || { echo "ERROR: Could not locate repo root. Set AP_REPO_ROOT."; exit 1; }

DEST_DIR="${AP_DEST_DIR:-${REPO_ROOT}/ai/openai/antifragile-progress-gpt/knowledge-files}"
mkdir -p "$DEST_DIR"

SRC_FRAMEWORK="${REPO_ROOT}/FRAMEWORK.md"
[[ -f "$SRC_FRAMEWORK" ]] || { echo "Missing source: $SRC_FRAMEWORK" >&2; exit 1; }

cp -f "$SRC_FRAMEWORK" "${DEST_DIR}/FRAMEWORK.md"

cat > "${DEST_DIR}/MANIFEST-${VERSION:-dev}.txt" <<EOF
# Antifragile-Progress Knowledge Manifest (for CustomGPT)

Upload this file to the CustomGPT Knowledge section:

FRAMEWORK.md   (source: ${SRC_FRAMEWORK})
EOF

echo "Repo root: ${REPO_ROOT}"
echo "Knowledge files prepared in: ${DEST_DIR}"
ls -1 "${DEST_DIR}"

if [[ "${1-}" == "-z" || "${1-}" == "--zip" ]]; then
  if command -v zip >/dev/null 2>&1; then
    TS="$(date +%Y%m%d-%H%M%S)"
    ( cd "$DEST_DIR" && zip -q "knowledge-upload-${TS}.zip" FRAMEWORK.md MANIFEST.txt )
    echo "Created zip package."
  else
    echo "zip not found; skipped."
  fi
fi
