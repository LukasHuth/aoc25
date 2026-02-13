FROM aoc-data:day5 AS data
  WORKDIR /artifact
FROM elixir:1.19.5-otp-28-alpine AS setup
  WORKDIR /app
  COPY . .
FROM setup AS test
  COPY test.txt /app/input.txt
  RUN set -eu &&\
    elixir main.exs 1 > output1.txt &&\
    diff -u expected_part1.txt output1.txt
  RUN set -eu &&\
    elixir main.exs 2 > output2.txt &&\
    diff -u expected_part2.txt output2.txt
FROM setup AS part1
  COPY --from=data /artifact/input.txt /app/input.txt

  ENTRYPOINT [ "elixir", "main.exs", "1" ]

FROM setup AS part2
  COPY --from=data /artifact/input.txt /app/input.txt

  ENTRYPOINT [ "elixir", "main.exs", "2" ]
