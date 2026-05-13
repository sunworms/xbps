#!/bin/bash
# gen-pkglist.sh <repo_dir>
# Generates a JSON array of packages found in the repo directory.
set -euo pipefail

REPO_DIR="${1:-.}"

echo "["
first=1
for xbps_file in "$REPO_DIR"/**/*.xbps "$REPO_DIR"/*.xbps; do
    [ -f "$xbps_file" ] || continue
    filename=$(basename "$xbps_file")
    # Parse: pkgname-version_revision.arch.xbps
    # e.g. helix-git-25.01_1.x86_64.xbps
    if [[ "$filename" =~ ^(.+)-([^-]+)_([0-9]+)\.([^.]+)\.xbps$ ]]; then
        name="${BASH_REMATCH[1]}"
        version="${BASH_REMATCH[2]}"
        revision="${BASH_REMATCH[3]}"
        arch="${BASH_REMATCH[4]}"
        size=$(stat -c%s "$xbps_file" 2>/dev/null || echo 0)
        [ "$first" -eq 0 ] && echo ","
        first=0
        printf '  {"name":"%s","version":"%s","revision":"%s","arch":"%s","filename":"%s","size":%d}' \
            "$name" "$version" "$revision" "$arch" "$filename" "$size"
    fi
done
echo ""
echo "]"
