FROM aoc-data:day1 AS data
  WORKDIR /artifact
FROM python:3.11.14-alpine3.23 AS setup
  WORKDIR /app
  COPY . .
FROM setup AS test
  COPY test.txt /app/input.txt
  RUN set -eu \
    result=$(python main.py) \
    echo ${result} \
    test "${result}" -eq 3
FROM setup
  COPY --from=data /artifact/input.txt /app/input.txt

  ENTRYPOINT [ "python", "main.py" ]

