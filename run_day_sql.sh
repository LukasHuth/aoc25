#!/bin/sh
set -eu

# This is a very britle script, but the structure of sql does not allow it to work witht the normal run script

DAY=$1

test "$DAY" -ge 1 -a "$DAY" -le 12

./build_day.sh $DAY

# test part 1
echo "▶ Running Test Part1"
containerIdTest1=$(docker run --rm -d aoc-day:day${DAY}-test)
trap 'docker stop ${containerIdTest1} > /dev/null' EXIT
docker exec "$containerIdTest1" sh -c '
until pg_isready -U runner -d aoc > /dev/null; do
  sleep 0.5
done
'
docker exec ${containerIdTest1} sh -c "psql -U runner -d aoc -f /app/part1.sql > /app/output1.txt"
docker exec ${containerIdTest1} diff -u /app/output1.txt /app/expected_part1.txt
docker stop ${containerIdTest1} > /dev/null
# end test

# test part 2
echo "▶ Running Test Part2"
containerIdTest2=$(docker run --rm -d aoc-day:day${DAY}-test)
trap 'docker stop ${containerIdTest2} > /dev/null' EXIT
docker exec "$containerIdTest2" sh -c '
until pg_isready -U runner -d aoc > /dev/null; do
  sleep 0.5
done
'
docker exec ${containerIdTest2} sh -c "psql -U runner -d aoc -f /app/part2.sql > /app/output2.txt"
docker exec ${containerIdTest2} diff -u /app/output2.txt /app/expected_part2.txt
docker stop ${containerIdTest2} > /dev/null
# end test

# run part1
echo "▶ Running Part1"
containerIdPart1=$(docker run --rm -d aoc-day:day${DAY}-part1)
trap 'docker stop ${containerIdPart1} > /dev/null' EXIT
sleep 2
docker exec ${containerIdPart1} psql -U runner -d aoc -f /app/part1.sql
docker stop ${containerIdPart1} > /dev/null
# end part1

# run part2
echo "▶ Running Part2"
containerIdPart2=$(docker run --rm -d aoc-day:day${DAY}-part2)
trap 'docker stop ${containerIdPart2} > /dev/null' EXIT
sleep 2
docker exec ${containerIdPart2} psql -U runner -d aoc -f /app/part2.sql
docker stop ${containerIdPart2} > /dev/null
# end part2
trap '' EXIT
