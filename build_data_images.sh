#!/bin/sh
set -eu

export DOCKER_BUILDKIT=1

for DAY in $(seq 1 12); do
  echo "▶ Building day $DAY"

  docker buildx build \
    --load \
    --build-arg DAY="$DAY" \
    --secret id=session,env=SESSION_TOKEN \
    -t "aoc-data:day$DAY" \
    -f datapuller/Dockerfile \
    .
  done

