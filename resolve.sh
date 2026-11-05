#!/bin/bash
# Prints GitHub step outputs: tag=<upstream tag> build=<true|false>.
# build=false when a release for that tag already exists with our REVISION.
set -euo pipefail

tag="${INPUT_REF:-}"
if [ -z "$tag" ]; then
    tag="$(git ls-remote --tags --refs https://github.com/Detanup01/gbe_fork.git 'release-*' \
        | sed 's|.*refs/tags/||' | grep -E '^release-[0-9]{4}_[0-9]{2}_[0-9]{2}$' | sort -V | tail -1)"
fi
[ -n "$tag" ] || { echo "no upstream tag found" >&2; exit 1; }

rev="$(cat REVISION)"
build=true
if [ "${FORCE:-false}" != true ] \
    && gh release view "$tag" --json body -q .body 2>/dev/null | grep -qx "revision=$rev"; then
    build=false
fi

echo "upstream=$tag revision=$rev build=$build" >&2
echo "tag=$tag"
echo "build=$build"
