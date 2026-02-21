CREATE TABLE Input (
  data TEXT
);
COPY Input(data) FROM '/docker-entrypoint-initdb.d/input.txt' WITH (FORMAT text);
