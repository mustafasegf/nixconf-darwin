#!/usr/bin/env bash
set -euo pipefail

OVERLAY_FILE="modules/common/default.nix"

LATEST=$(curl -s "https://api.github.com/repos/ghostty-org/ghostty/tags?per_page=1" |
	grep '"name"' | head -1 | sed 's/.*"v\(.*\)".*/\1/')

if [ -z "$LATEST" ]; then
	echo "Failed to fetch latest Ghostty version from GitHub"
	exit 1
fi

CURRENT=$(sed -n '/ghostty-bin/,/version = "/{s/.*version = "\(.*\)".*/\1/p;}' "$OVERLAY_FILE" | head -1)

echo "Current: $CURRENT"
echo "Latest:  $LATEST"

if [ "$CURRENT" = "$LATEST" ]; then
	echo "Already up to date."
	exit 0
fi

echo "Fetching hash for Ghostty v${LATEST}..."
HASH=$(nix-prefetch-url "https://release.files.ghostty.org/${LATEST}/Ghostty.dmg" 2>/dev/null)
SRI=$(nix hash convert --to sri --hash-algo sha256 "$HASH")

echo "New hash: $SRI"

OLD_HASH=$(sed -n '/ghostty-bin/,/hash = "/{s/.*hash = "\(.*\)".*/\1/p;}' "$OVERLAY_FILE" | head -1)

sed -i '' "/ghostty-bin/,/hash = \"/{
  s|version = \"${CURRENT}\"|version = \"${LATEST}\"|
  s|hash = \"${OLD_HASH}\"|hash = \"${SRI}\"|
}" "$OVERLAY_FILE"

echo "Updated Ghostty from $CURRENT to $LATEST"
echo "Run 'nix run .#activate' to apply."
