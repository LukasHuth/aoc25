#!/bin/sh
set -eu

DAY=$1

test "$DAY" -ge 1 -a "$DAY" -le 12

DAY_PATH="day${DAY}"

cd ${DAY_PATH}

echo "▶ Building day $DAY"

docker buildx build --target test -t "aoc-day:day${DAY}-test" .
docker buildx build -t "aoc-day:day${DAY}" .

