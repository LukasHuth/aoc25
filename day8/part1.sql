SET client_min_messages TO WARNING;
CREATE TABLE Part1_Lines (
  id SERIAL PRIMARY KEY,
  line TEXT
);
INSERT INTO Part1_Lines (line) 
  SELECT unnest(string_to_array(data, '\n')) as line
  FROM Input;
CREATE TABLE Part1_Coordinates (
  id SERIAL PRIMARY KEY,
  x BIGINT,
  y BIGINT,
  z BIGINT
);
INSERT INTO Part1_Coordinates (x, y, z)
  SELECT
    split_part(line, ',', 1)::int,
    split_part(line, ',', 2)::int,
    split_part(line, ',', 3)::int
  FROM Part1_Lines;
CREATE TABLE Part1_Distances (
  node_1 int,
  node_2 int,
  distance double precision,
  FOREIGN KEY (node_1) REFERENCES Part1_Coordinates(id),
  FOREIGN KEY (node_2) REFERENCES Part1_Coordinates(id)
);
INSERT INTO Part1_Distances (node_1, node_2, distance)
  SELECT t1.id, t2.id, sqrt((t2.x-t1.x)*(t2.x-t1.x) + (t2.y-t1.y)*(t2.y-t1.y) + (t2.z-t1.z)*(t2.z-t1.z)) as distance
  FROM Part1_Coordinates as t1, Part1_Coordinates as t2
  WHERE (t1.x, t1.y, t1.z) < (t2.x, t2.y, t2.z);

CREATE TABLE Part1_orderedEdges (
  node_1 INT REFERENCES Part1_Coordinates(id),
  node_2 INT REFERENCES Part1_Coordinates(id),
  distance double precision,
  rn BIGINT
);
INSERT INTO Part1_orderedEdges
  SELECT *, ROW_NUMBER() OVER (ORDER BY distance) AS rn
  FROM Part1_Distances;

-- Take the least distant node that was not used.
-- Check whether it is fully in a network already, if yes, skip
-- if not append to a network or create a new network

CREATE TABLE Part1_networks (
  network_id INT,
  node_id INT REFERENCES Part1_Coordinates(id),
  PRIMARY KEY (node_id)
);
-- insert here. each time checking whether it goes into another network or if a new network has to be created.
-- node appending with unnest(ARRAY[<nodes to insert>]) EXCEPT unnest(nodes) this automatically solves to not insert nodes that are already in, be it 1 or 2, do this when at least ony containing
-- if none containing, create new entry with ARRAY[<nodes to insert>]
INSERT INTO Part1_networks (network_id, node_id) SELECT id, id FROM Part1_Coordinates;

CREATE TABLE Part1_rnLimit (limit_value INT);
INSERT INTO Part1_rnLimit VALUES (:RN_LIMIT);

DO $$
DECLARE
  rec RECORD;
  net1 INT;
  net2 INT; 
  rn_limit INT;
BEGIN
  SELECT limit_value INTO rn_limit FROM Part1_rnLimit LIMIT 1;
  FOR rec IN
    SELECT node_1, node_2
    FROM Part1_orderedEdges
    WHERE rn <= rn_limit
    ORDER BY rn
  LOOP
    SELECT network_id INTO net1
      FROM Part1_networks n
      WHERE n.node_id = rec.node_1;

    SELECT network_id INTO net2
      FROM Part1_networks n
      WHERE n.node_id = rec.node_2;

    IF net1 <> net2 THEN
      UPDATE Part1_networks
        SET network_id = LEAST(net1, net2)
        WHERE network_id = GREATEST(net1, net2);
    END IF;
  END LOOP;
END
$$;

WITH net_sizes AS (
  SELECT COUNT(node_id) as size
  FROM Part1_networks
  GROUP BY network_id
  ORDER BY size DESC
  LIMIT 3
)
SELECT ROUND(EXP(SUM(LN(size)))) AS result
FROM net_sizes;
