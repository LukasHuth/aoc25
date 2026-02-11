#!/bin/sh
set -eu

export DOCKER_BUILDKIT=1

tempfile=$(mktemp)
trap 'rm -f "$tempfile"' EXIT

if [ -z "${SESSION_TOKEN}" ]; then
  echo "Missing SESSION_TOKEN"
  exit 1
fi

echo "${SESSION_TOKEN}" > "${tempfile}"

for DAY in $(seq 1 12); do
  echo "▶ Building day $DAY"

  docker buildx build \
    --load \
    --no-cache \
    --build-arg DAY="$DAY" \
    --secret id=session,src="${tempfile}" \
    -t "aoc-data:day$DAY" \
    -f datapuller/Dockerfile \
    .
  done

