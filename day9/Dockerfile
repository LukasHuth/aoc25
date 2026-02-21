FROM aoc-data:day9 AS data
  WORKDIR /artifact
FROM node:25-alpine3.23 AS setup
  WORKDIR /app
  COPY . .
  RUN npm install -g typescript
  RUN npm install
FROM setup AS test
  COPY test.txt /app/input.txt
  RUN set -eu;\
    tsc index.ts --downlevelIteration;\
    node . 1 > output1.txt;\
    diff -u expected_part1.txt output1.txt
  RUN set -eu;\
    tsc index.ts --downlevelIteration;\
    node . 2 > output2.txt;\
    diff -u expected_part2.txt output2.txt
FROM setup AS part1
  COPY --from=data /artifact/input.txt /app/input.txt

  RUN set -eu; tsc index.ts --downlevelIteration

  ENTRYPOINT [ "node", ".", "1" ]

FROM setup AS part2
  COPY --from=data /artifact/input.txt /app/input.txt

  RUN set -eu; tsc index.ts --downlevelIteration

  ENTRYPOINT [ "node", ".", "2" ]
