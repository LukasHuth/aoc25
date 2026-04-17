FROM aoc-data:day12 AS data
  WORKDIR /artifact
FROM alpine:3.23 AS setup
  WORKDIR /app
  RUN apk add build-base nasm
  COPY . .
  RUN make install
FROM setup AS test
  COPY test.txt /app/input.txt
  RUN set -eu &&\
    day12 1 > output1.txt &&\
    diff -u expected_part1.txt output1.txt
  RUN set -eu &&\
    day12 2 > output2.txt &&\
    diff -u expected_part2.txt output2.txt
FROM setup AS part1
  COPY --from=data /artifact/input.txt /app/input.txt

  ENTRYPOINT [ "day12", "1" ]

FROM setup AS part2
  COPY --from=data /artifact/input.txt /app/input.txt

  ENTRYPOINT [ "day12", "2" ]
