#!/bin/bash
set -euo pipefail
# Niblet's reviewed runtime adds frame_keys; upstream Pixlet cannot evaluate it.
version=$(cat PIXLET_VERSION)
test "$version" = v0.54.13 || { echo 'Update the reviewed runtime checksum with PIXLET_VERSION.' >&2; exit 1; }
archive="niblet_${version}_linux_amd64.tar.gz"
curl --fail --location --silent --show-error "https://cdn.heyniblet.com/web-assets/releases/niblet-cli/$version/$archive" -o "$RUNNER_TEMP/$archive"
printf '%s  %s\n' d45bf6d802a296594b38a09f4c3d479187a83819e392231cfbcd3e55bed5b5ea "$RUNNER_TEMP/$archive" | sha256sum --check
sudo tar -C /usr/local/bin -xzf "$RUNNER_TEMP/$archive" niblet pixlet
