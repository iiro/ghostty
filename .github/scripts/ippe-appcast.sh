#!/usr/bin/env bash
# Prints the Sparkle appcast for a Ghostty by Ippe release.
#
# Usage: ippe-appcast.sh <version> <build> <tag> <zip> <signature>
#
# <signature> is the output of Sparkle's sign_update for <zip>, e.g.
# `sparkle:edSignature="..." length="123"`. The appcast lists only this
# release: it is attached to every release and the app reads it from the
# latest one, so older entries would never be offered anyway.
set -euo pipefail

version=$1
build=$2
tag=$3
zip=$4
signature=$5
repo=${GITHUB_REPOSITORY:-iiro/ghostty}
release_url="https://github.com/$repo/releases/tag/$tag"

cat <<EOF
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>Ghostty by Ippe</title>
    <item>
      <title>Ghostty by Ippe $version</title>
      <pubDate>$(LC_ALL=C date -u "+%a, %d %b %Y %H:%M:%S +0000")</pubDate>
      <sparkle:version>$build</sparkle:version>
      <sparkle:shortVersionString>$version</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>13.0.0</sparkle:minimumSystemVersion>
      <sparkle:fullReleaseNotesLink>$release_url</sparkle:fullReleaseNotesLink>
      <description><![CDATA[<p>See the <a href="$release_url">release notes</a> for what changed.</p>]]></description>
      <enclosure url="https://github.com/$repo/releases/download/$tag/$(basename "$zip")" type="application/octet-stream" $signature/>
    </item>
  </channel>
</rss>
EOF
