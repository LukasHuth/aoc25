FROM aoc-data:day6 AS data
  WORKDIR /artifact
FROM alpine:3.23 AS base
  RUN apk add zig

FROM base AS setup
  WORKDIR /app
  COPY . .

FROM setup AS test
  COPY src/test.txt /app/input.txt
  RUN set -eu && zig build test

FROM setup AS compile
  WORKDIR /app
  RUN zig build
  RUN cp /app/zig-out/bin/day6 /usr/local/bin/day6

FROM compile AS part1
  COPY --from=data /artifact/input.txt /app/input.txt

  ENTRYPOINT [ "day6", "1" ]

FROM compile AS part2
  COPY --from=data /artifact/input.txt /app/input.txt

  ENTRYPOINT [ "day6", "2" ]
