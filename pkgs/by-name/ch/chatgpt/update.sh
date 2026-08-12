#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl dpkg

set -euo pipefail

url="https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

curl --fail --location --output "$tmpdir/chatgpt_amd64.deb" "$url"

version=$(dpkg-deb --field "$tmpdir/chatgpt_amd64.deb" Version)
hash=$(nix hash file "$tmpdir/chatgpt_amd64.deb")

SOURCE_NIX="$(dirname ${BASH_SOURCE[0]})/source.nix"

cat > "${SOURCE_NIX}" << _EOF_
{
  version = "$version";
  src = {
    url = "$url";
    hash = "$hash";
  };
}
_EOF_
