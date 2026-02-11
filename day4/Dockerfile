FROM aoc-data:day4 AS data
  WORKDIR /artifact
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS setup
  WORKDIR /app
  COPY . .
  RUN dotnet build -c Release
FROM setup AS test
  COPY test.txt /app/input.txt
  RUN set -eu &&\
    dotnet bin/Release/net8.0/day4.dll 1 > output1.txt &&\
    diff -u expected_part1.txt output1.txt
  RUN set -eu &&\
    dotnet bin/Release/net8.0/day4.dll 2 > output2.txt &&\
    diff -u expected_part2.txt output2.txt
FROM setup AS part1
  COPY --from=data /artifact/input.txt /app/input.txt

  ENTRYPOINT [ "dotnet", "bin/Release/net8.0/day4.dll", "1" ]

FROM setup AS part2
  COPY --from=data /artifact/input.txt /app/input.txt

  ENTRYPOINT [ "dotnet", "bin/Release/net8.0/day4.dll", "2" ]
