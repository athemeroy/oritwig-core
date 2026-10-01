#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
root=$(pwd -P)
[[ $(git rev-parse --show-toplevel) == "$root" ]] || { echo 'Package from the Oritwig Core Git checkout, not a parent workspace.' >&2; exit 2; }
[[ -z $(git status --porcelain --untracked-files=normal) ]] || { echo 'Commit a clean source tree before packaging.' >&2; exit 2; }
commit=$(git rev-parse HEAD)
./tools/build-core.sh
[[ $(git rev-parse HEAD) == "$commit" && -z $(git status --porcelain --untracked-files=normal) ]] || { echo 'Source changed during the build.' >&2; exit 2; }
mkdir -p artifacts/core
cp shared/core/build/outputs/aar/core-release.aar artifacts/core/oritwig-core.aar
git archive --format=tar --prefix=oritwig-core/ HEAD | gzip -n > "artifacts/core/oritwig-core-$commit-source.tar.gz"
printf 'source_commit=%s\nlicense=GPL-3.0-or-later\n' "$commit" > artifacts/core/BUILD-INFO.txt
(cd artifacts/core && sha256sum oritwig-core.aar oritwig-core-*-source.tar.gz BUILD-INFO.txt > SHA256SUMS)
