#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Antifragile-Progress – release helper
# - Aggregates #feat/#fix/#docs/#build commit subjects into a single list
# - Works with or without previous tags
# - Optional preview mode, force, silent, since-tag, and GitHub Release (no assets)
#
# Usage:
#   ./make-release.sh v1.0.0
#   ./make-release.sh --preview v1.0.0
#   ./make-release.sh --force v1.0.0
#   ./make-release.sh --since v0.2.0 v1.0.0
#   ./make-release.sh --repo owner/name v1.0.0
# -----------------------------------------------------------------------------

PREVIEW=false
FORCE=false
SILENT=false
SINCE_TAG=""
REPO=""
VERSION=""

usage() {
  cat <<EOF
Usage: $0 [--preview] [--force] [--silent] [--since <tag>] [--repo <owner/name>] <version>
Example: $0 v1.0.0
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --preview) PREVIEW=true; shift ;;
    --force)   FORCE=true; shift ;;
    --silent)  SILENT=true; shift ;;
    --since)   SINCE_TAG="${2:-}"; shift 2 ;;
    --repo)    REPO="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    v*)        VERSION="$1"; shift ;;
    *)         echo "Unknown arg: $1"; usage; exit 1 ;;
  esac
done

if [[ -z "$VERSION" ]]; then
  echo "Error: version (e.g., v1.0.0) is required."
  usage; exit 1
fi

# --- Ensure we are inside a git repo ---
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Error: not a git repository (run inside your repo)."
  exit 1
fi

git fetch --tags --quiet || true
DATE="$(date +%Y-%m-%d)"

# --- Determine "since" anchor ---
if [[ -n "$SINCE_TAG" ]]; then
  LAST_TAG="$SINCE_TAG"
else
  LAST_TAG="$(git describe --tags --abbrev=0 2>/dev/null || true)"
fi

RANGE=""
if [[ -n "$LAST_TAG" ]]; then
  RANGE="${LAST_TAG}..HEAD"
fi

# --- Build changes list (categorised) ---
CHANGES="$(git log --no-decorate --pretty=format:'%s' ${RANGE} | grep -E '(^#feat|^#fix|^#docs|^#build)' || true)"
if [[ -z "$CHANGES" ]]; then
  CHANGES="(no categorized changes; consider adding #feat/#fix/#docs/#build prefixes)"
fi

if [[ -n "$LAST_TAG" ]]; then
  SINCE_LINE="since **${LAST_TAG}**"
else
  SINCE_LINE="(first tagged release)"
fi

RELEASE_BODY="$(cat <<'EOF'
# Antifragile-Progress — __VERSION__ (released __DATE__)

__SINCE_LINE__

## Changes
__CHANGES__

## Notes
- Knowledge-only framework.
- Use this framework to drive lean, antifragile progress across initiatives.
EOF
)"
RELEASE_BODY="${RELEASE_BODY//__VERSION__/${VERSION}}"
RELEASE_BODY="${RELEASE_BODY//__DATE__/${DATE}}"
RELEASE_BODY="${RELEASE_BODY//__SINCE_LINE__/${SINCE_LINE}}"
RELEASE_BODY="${RELEASE_BODY//__CHANGES__/${CHANGES}}"

# --- Preview or confirm ---
if [[ "$SILENT" = false ]]; then
  echo "========= ${PREVIEW:+PREVIEW: }Release Notes for ${VERSION} =========="
  printf "%s\n" "$RELEASE_BODY"
  echo "========== END ${PREVIEW:+PREVIEW }=========="
  if [[ "$PREVIEW" = false && "$FORCE" = false ]]; then
    read -r -p "Proceed with tagging and publishing? (Y/n): " CONFIRM
    if [[ "${CONFIRM:-Y}" != "Y" && "${CONFIRM:-Y}" != "y" ]]; then
      echo "Aborted."
      exit 0
    fi
  fi
fi

# --- Stop here if preview ---
if [[ "$PREVIEW" = true ]]; then
  exit 0
fi

# --- Create or move tag ---
if git rev-parse "${VERSION}" >/dev/null 2>&1; then
  if [[ "$FORCE" = true ]]; then
    git tag -f "${VERSION}"
  else
    echo "Tag ${VERSION} already exists. Use --force to retag."; exit 1
  fi
else
  git tag "${VERSION}"
fi

# --- Push tag ---
git push origin "${VERSION}"

# --- GitHub Release (optional) ---
if command -v gh >/dev/null 2>&1; then
  RELEASE_NAME="${VERSION}"
  RELEASE_TITLE="Release ${VERSION}"
  if [[ -n "$REPO" ]]; then
    TARGET_REPO=(--repo "$REPO")
  else
    TARGET_REPO=()
  fi

  if gh release view "$RELEASE_NAME" "${TARGET_REPO[@]}" >/dev/null 2>&1; then
    echo "GitHub Release ${RELEASE_NAME} already exists. Skipping creation."
  else
    gh release create "$RELEASE_NAME" \
      --title "$RELEASE_TITLE" \
      --notes "$RELEASE_BODY" \
      "${TARGET_REPO[@]}"
    [[ "$SILENT" = false ]] && echo "✅ Created GitHub Release ${RELEASE_NAME}"
  fi
else
  echo "⚠️  GitHub CLI (gh) not found. Skipping GitHub Release creation."
fi

# --- Build CustomGPT knowledge files (FRAMEWORK-only) ---
# Always inline here to ensure versioned manifest + zip.
if command -v git >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
else
  REPO_ROOT="$(pwd)"
fi

AP_GPT_DIR="${REPO_ROOT}/ai/openai/antifragile-progress-gpt"
DEST_DIR="${AP_GPT_DIR}/knowledge-files"
SRC_FRAMEWORK="${REPO_ROOT}/FRAMEWORK.md"

echo "🔧 Preparing AntifragileProgressGPT knowledge files for ${VERSION} ..."
if [[ -f "$SRC_FRAMEWORK" ]]; then
  mkdir -p "$DEST_DIR"
  cp -f "$SRC_FRAMEWORK" "${DEST_DIR}/FRAMEWORK.md"

  MANIFEST_FILE="${DEST_DIR}/MANIFEST-${VERSION}.txt"
  cat > "$MANIFEST_FILE" <<EOF
# Antifragile-Progress Knowledge Manifest (for CustomGPT) — ${VERSION}

Upload this file:
- FRAMEWORK.md   (source: ${SRC_FRAMEWORK})
EOF

  if command -v zip >/dev/null 2>&1; then
    ZIP_PATH="${DEST_DIR}/knowledge-upload-${VERSION}.zip"
    ( cd "$DEST_DIR" && zip -q "$ZIP_PATH" FRAMEWORK.md "$(basename "$MANIFEST_FILE")" )
    echo "✅ Built knowledge bundle: $ZIP_PATH"
  else
    echo "✅ Built knowledge files (no 'zip' found to package)"
  fi
else
  echo "⚠️  Skipped knowledge build (missing ${SRC_FRAMEWORK})"
fi

echo "🎉 Release ${VERSION} complete."
