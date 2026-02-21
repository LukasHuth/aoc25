SET client_min_messages TO WARNING;
CREATE TABLE Part1_Lines (
  id SERIAL PRIMARY KEY,
  line TEXT
);
INSERT INTO Part1_Lines (line) 
  SELECT unnest(string_to_array(data, '\n')) as line
  FROM Input;
CREATE TABLE Part1_Coordinates (
  x INTEGER,
  y INTEGER,
  z INTEGER
);
INSERT INTO Part1_Coordinates (x, y, z)
  SELECT
    split_part(line, ',', 1)::int,
    split_part(line, ',', 2)::int,
    split_part(line, ',', 3)::int
  FROM Part1_Lines;
CREATE TABLE Part1_Distances (
  x_1 BIGINT,
  y_1 BIGINT,
  z_1 BIGINT,
  x_2 BIGINT,
  y_2 BIGINT,
  z_2 BIGINT,
  distance double precision
);
INSERT INTO Part1_Distances (x_1, y_1, z_1, x_2, y_2, z_2, distance)
  SELECT t1.x, t1.y, t1.z, t2.x, t2.y, t2.z, sqrt((t2.x-t1.x)*(t2.x-t1.x) + (t2.y-t1.y)*(t2.y-t1.y) + (t2.z-t1.z)*(t2.z-t1.z)) as distance
  FROM Part1_Coordinates as t1, Part1_Coordinates as t2
  WHERE (t1.x, t1.y, t1.z) < (t2.x, t2.y, t2.z);

-- WITH RECURSIVE ordered_edges AS (
--   SELECT *, ROW_NUMBER() OVER (ORDER BY distance) AS rn
--   FROM Part1_Distances
-- ),
-- network AS (
--   SELECT rn, x_1, y_1, z_1, x_2, y_2, z_2, distance, ARRAY[ROW(x_1, y_1, z_1), ROW(x_2, y_2, z_2)] as nodes
--   FROM ordered_edges
--   WHERE rn = 1
--   UNION ALL
--   SELECT e.rn, e.x_1, e.y_1, e.z_1, e.x_2, e.y_2, e.z_2, e.distance, n.nodes ||
--     CASE
--       WHEN ROW(e.x_1, e.y_1, e.z_1) <> ANY(n.nodes) AND ROW(e.x_2, e.y_2, e.z_2) <> ANY(n.nodes)
--         THEN ARRAY[ ROW(e.x_1, e.y_1, e.z_1), ROW(e.x_2, e.y_2, e.z_2)]
--       WHEN ROW(e.x_1, e.y_1, e.z_1) = ANY(n.nodes) AND ROW(e.x_2, e.y_2, e.z_2) <> ANY(n.nodes)
--         THEN ARRAY[ ROW(e.x_2, e.y_2, e.z_2) ]
--       WHEN ROW(e.x_1, e.y_1, e.z_1) <> ANY(n.nodes) AND ROW(e.x_2, e.y_2, e.z_2) = ANY(n.nodes)
--         THEN ARRAY[ ROW(e.x_1, e.y_1, e.z_1) ]
--       ELSE NULL
--     END
--     FROM network n
--     JOIN ordered_edges e
--       ON e.rn > n.rn + 1
--   WHERE NOT (
--     ROW(e.x_1,e.y_1,e.z_1) = ANY(n.nodes)
--     AND
--     ROW(e.x_2,e.y_2,e.z_2) = ANY(n.nodes)
--   )
-- ) SELECT * FROM network ORDER BY rn LIMIT 1;
CREATE TABLE Part1_orderedEdges (
  x_1 BIGINT,
  y_1 BIGINT,
  z_1 BIGINT,
  x_2 BIGINT,
  y_2 BIGINT,
  z_2 BIGINT,
  distance double precision,
  rn BIGINT
);
INSERT INTO Part1_orderedEdges
  SELECT *, ROW_NUMBER() OVER (ORDER BY distance) AS rn
  FROM Part1_Distances;

-- Take the least distant node that was not used.
-- Check whether it is fully in a network already, if yes, skip
-- if not append to a network or create a new network

CREATE TYPE Coordinate AS (
  x BIGINT,
  y BIGINT,
  z BIGINT
);
CREATE TABLE Part1_networks (
  last_rn BIGINT,
  nodes Coordinate[]
);
-- insert here. each time checking whether it goes into another network or if a new network has to be created.
-- node appending with unnest(ARRAY[<nodes to insert>]) EXCEPT unnest(nodes) this automatically solves to not insert nodes that are already in, be it 1 or 2, do this when at least ony containing
-- if none containing, create new entry with ARRAY[<nodes to insert>]
