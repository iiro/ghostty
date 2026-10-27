#!/usr/bin/env bash
# Prints the release notes for a Ghostty by Ippe release in Markdown.
#
# Usage: ippe-release-notes.sh <tag> [<previous tag>]
#
# Run from a full-history checkout of the commit being released. Upstream
# main is fetched to find what the fork changes on top of upstream, which
# keeps working after the branch is rebased.
set -euo pipefail

tag=$1
prev=${2:-}
repo=${GITHUB_REPOSITORY:-iiro/ghostty}
upstream_url=https://github.com/ghostty-org/ghostty.git

git fetch --quiet --tags "$upstream_url" main:refs/ippe-notes/upstream-main
base=$(git merge-base HEAD refs/ippe-notes/upstream-main)
base_short=$(git rev-parse --short=7 "$base")
base_date=$(TZ=UTC git log -1 --date=format-local:%Y-%m-%d --format=%cd "$base")
base_describe=$(git describe --tags --match 'v[0-9]*' "$base" 2>/dev/null || true)

echo "## Changes in this fork"
echo
git log --no-merges --reverse --format="- %s ([%h](https://github.com/$repo/commit/%H))" "$base..HEAD"
echo
echo "## Upstream base"
echo
echo -n "Built on [ghostty-org/ghostty@$base_short](https://github.com/ghostty-org/ghostty/commit/$base) from $base_date"
if [ -n "$base_describe" ]; then
  echo " (\`$base_describe\`)."
else
  echo "."
fi
echo

if [ -n "$prev" ]; then
  echo "**Full diff since the previous release:** [$prev...$tag](https://github.com/$repo/compare/$prev...$tag)"
  echo
fi

cat <<'EOF'
## Install

**macOS** (universal: Apple Silicon and Intel): unzip, move `Ghostty by Ippe.app` to /Applications, then run:

```
xattr -dr com.apple.quarantine "/Applications/Ghostty by Ippe.app"
```

The app is ad-hoc signed and not notarized, so macOS blocks it until the quarantine flag is removed. This is needed only for the first install: after that, the app updates itself from this fork's releases (Ghostty menu → Check for Updates).

**Linux** (x86_64 or aarch64): built on Ubuntu 26.04, so it needs a similarly recent distro: glibc 2.43+, GTK 4 and libadwaita 1.7+, and gtk4-layer-shell (e.g. Ubuntu 26.04, or a current Fedora or Arch). Extract into `~/.local` with `tar -xzf <file>.tar.gz -C ~/.local` and make sure `~/.local/bin` is on your PATH. On Linux the app ID is still upstream's `com.mitchellh.ghostty`, so this replaces rather than runs beside an official Ghostty install. The link fix uses Ctrl+click on Linux.
EOF
