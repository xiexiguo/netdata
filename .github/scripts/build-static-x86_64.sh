#!/bin/sh
#
# Builds the netdata-vX.Y.Z-xxxx.gz.run (static x86_64) artifact.

set -e

# shellcheck source=.github/scripts/functions.sh
. "$(dirname "$0")/functions.sh"

NAME="${NAME:-netdata}"
VERSION="${VERSION:-"$(git describe)"}"
BASENAME="$NAME-$VERSION"

prepare_build() {
  progress "Preparing build"
  (
    test -d artifacts || mkdir -p artifacts
  ) >&2
}

build_static_x86_64() {
  progress "Building static x86_64"
  (
    USER="" ./packaging/makeself/build-x86_64-static.sh
  ) >&2
}

prepare_assets() {
  progress "Preparing assets"
  (
    cp packaging/version artifacts/latest-version.txt

    cd artifacts || exit 1
    ln -s "${BASENAME}.gz.run" netdata-latest.gz.run
    sha256sum -b ./* > "sha256sums.txt"
  ) >&2
}

steps="prepare_build build_static_x86_64"
steps="$steps prepare_assets"

_main() {
  for step in $steps; do
    if ! run "$step"; then
      if [ -t 1 ]; then
        debug
      else
        fail "Build failed"
      fi
    fi
  done

  echo "🎉 All Done!"
}

if [ -n "$0" ] && [ x"$0" != x"-bash" ]; then
  _main "$@"
fi
