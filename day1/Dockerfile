FROM aoc-data:day1 AS data
  WORKDIR /artifact
FROM python:3.11.14-alpine3.23 AS setup
  WORKDIR /app
  COPY . .
FROM setup AS test
  COPY test.txt /app/input.txt
  RUN set -eu &&\
    result=$(python main.py 1) &&\
    echo ${result} &&\
    test "${result}" -eq 3
  RUN set -eu &&\
    result=$(python main.py 2) &&\
    echo ${result} &&\
    test "${result}" -eq 6
FROM setup AS part1
  COPY --from=data /artifact/input.txt /app/input.txt

  ENTRYPOINT [ "python", "main.py", "1" ]

FROM setup AS part2
  COPY --from=data /artifact/input.txt /app/input.txt

  ENTRYPOINT [ "python", "main.py", "2" ]
