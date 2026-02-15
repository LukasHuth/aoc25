FROM aoc-data:day7 AS data
  WORKDIR /artifact
FROM openjdk:27-ea-slim-trixie AS setup
  WORKDIR /app
  COPY . .
  RUN javac Main.java
FROM setup AS test
  COPY test.txt /app/input.txt
  RUN set -eu &&\
    java Main 1 > output1.txt &&\
    diff -u expected_part1.txt output1.txt
  RUN set -eu &&\
    java Main 2 > output2.txt &&\
    diff -u expected_part2.txt output2.txt
FROM setup AS part1
  COPY --from=data /artifact/input.txt /app/input.txt

  ENTRYPOINT [ "java", "Main", "1" ]

FROM setup AS part2
  COPY --from=data /artifact/input.txt /app/input.txt

  ENTRYPOINT [ "java", "Main", "2" ]
