#!/bin/sh
set -eu

DAY=$1

test "$DAY" -ge 1 -a "$DAY" -le 12

./build_day.sh $DAY

part1=$(docker run aoc-day:day${DAY}-part1)
echo "part1:  ${part1}"
part2=$(docker run aoc-day:day${DAY}-part2)
echo "part2:  ${part2}"
