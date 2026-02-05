FROM alpine:3.23.3

RUN apk add --no-cache \
    curl \
        ca-certificates \
            bash

ARG DAY

RUN set -eu

RUN test "$DAY" -ge 1 -a "$DAY" -le 12

WORKDIR /artifact

RUN --mount=type=secret,id=session curl -A "Mozilla/5.0 (compatible; aoc-bot/1.0)" -H "Cookie: session=$(cat /run/secrets/session)" "https://adventofcode.com/2025/day/${DAY}/input" -o input.txt
