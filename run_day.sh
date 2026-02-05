#!/bin/sh
set -eu

DAY=$1

test "$DAY" -ge 1 -a "$DAY" -le 12

./build_day.sh $DAY

docker run aoc-day:day${DAY}
