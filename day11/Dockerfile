FROM aoc-data:day11 AS data
  WORKDIR /artifact
FROM rust:1.93.1-alpine3.23 AS setup
  WORKDIR /app
  COPY src/ src/
  COPY Cargo.toml Cargo.toml
  COPY --from=data /artifact/input.txt /app/input.txt
  RUN cargo build --release
  RUN cp target/release/day11 /usr/local/bin/day11
FROM setup AS test
  COPY test.txt /app/input.txt
  RUN set -eu; cargo test --release
FROM setup AS part1

  ENTRYPOINT [ "day11", "1" ]

FROM setup AS part2

  ENTRYPOINT [ "day11", "2" ]
