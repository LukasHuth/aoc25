FROM aoc-data:day8 AS data
  WORKDIR /artifact
FROM postgres:15-alpine3.23 AS setup
  WORKDIR /app
  RUN chown -R postgres /app
  
  ENV POSTGRES_DB=aoc
  ENV POSTGRES_USER=runner
  ENV POSTGRES_PASSWORD=secret

  COPY init.sql /docker-entrypoint-initdb.d/
  COPY part1.sql /app/part1.sql
  COPY part2.sql /app/part2.sql
  USER postgres
FROM setup AS test
  COPY test.txt /docker-entrypoint-initdb.d/input.txt
  COPY expected_part1.txt /app/expected_part1.txt
  COPY expected_part2.txt /app/expected_part2.txt
FROM setup AS part1
  COPY --from=data /artifact/input.txt /docker-entrypoint-initdb.d/input.txt

FROM setup AS part2
  COPY --from=data /artifact/input.txt /docker-entrypoint-initdb.d/input.txt
