#! /bin/bash
set -e

docker build --build-arg REPO=${GITHUB_REPOSITORY,,} -t ghcr.io/thelamer/tlosint-docker:latest .
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v $(pwd):/tmp \
  ghcr.io/anchore/syft:latest \
  ghcr.io/thelamer/tlosint-docker:latest -o table=/tmp/package_versions_check.txt
if [ ! -f 'package_versions.txt' ]; then
  mv package_versions_check.txt package_versions.txt
elif ! diff -q package_versions_check.txt package_versions.txt; then
  mv package_versions_check.txt package_versions.txt
else
  rm -f package_versions_check.txt
fi
