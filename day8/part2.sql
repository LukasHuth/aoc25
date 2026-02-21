SET client_min_messages TO WARNING;
CREATE TABLE Part2_Lines (
  id SERIAL PRIMARY KEY,
  line TEXT
);
INSERT INTO Part2_Lines (line) 
  SELECT unnest(string_to_array(data, '\n')) as line
  FROM Input;
CREATE TABLE Part2_Coordinates (
  id SERIAL PRIMARY KEY,
  x BIGINT,
  y BIGINT,
  z BIGINT
);
INSERT INTO Part2_Coordinates (x, y, z)
  SELECT
    split_part(line, ',', 1)::int,
    split_part(line, ',', 2)::int,
    split_part(line, ',', 3)::int
  FROM Part2_Lines;
CREATE TABLE Part2_Distances (
  node_1 int,
  node_2 int,
  distance double precision,
  FOREIGN KEY (node_1) REFERENCES Part2_Coordinates(id),
  FOREIGN KEY (node_2) REFERENCES Part2_Coordinates(id)
);
INSERT INTO Part2_Distances (node_1, node_2, distance)
  SELECT t1.id, t2.id, sqrt((t2.x-t1.x)*(t2.x-t1.x) + (t2.y-t1.y)*(t2.y-t1.y) + (t2.z-t1.z)*(t2.z-t1.z)) as distance
  FROM Part2_Coordinates as t1, Part2_Coordinates as t2
  WHERE (t1.x, t1.y, t1.z) < (t2.x, t2.y, t2.z);

CREATE TABLE Part2_orderedEdges (
  node_1 INT REFERENCES Part2_Coordinates(id),
  node_2 INT REFERENCES Part2_Coordinates(id),
  distance double precision,
  rn BIGINT
);
INSERT INTO Part2_orderedEdges
  SELECT *, ROW_NUMBER() OVER (ORDER BY distance) AS rn
  FROM Part2_Distances;

-- Take the least distant node that was not used.
-- Check whether it is fully in a network already, if yes, skip
-- if not append to a network or create a new network

CREATE TABLE Part2_networks (
  network_id INT,
  node_id INT REFERENCES Part2_Coordinates(id),
  PRIMARY KEY (node_id)
);
-- insert here. each time checking whether it goes into another network or if a new network has to be created.
-- node appending with unnest(ARRAY[<nodes to insert>]) EXCEPT unnest(nodes) this automatically solves to not insert nodes that are already in, be it 1 or 2, do this when at least ony containing
-- if none containing, create new entry with ARRAY[<nodes to insert>]
INSERT INTO Part2_networks (network_id, node_id) SELECT id, id FROM Part2_Coordinates;

CREATE TABLE Part2_last_checked (
  id SERIAL PRIMARY KEY,
  node_1 INT REFERENCES Part2_Coordinates(id),
  node_2 INT REFERENCES Part2_Coordinates(id),
  updated BOOLEAN
);

DO $$
DECLARE
  rec RECORD;
  net1 INT;
  net2 INT; 
  last_node_1 INT;
  last_node_2 INT;
  updated BOOLEAN;
BEGIN
  updated := FALSE;
  FOR rec IN
    SELECT node_1, node_2
    FROM Part2_orderedEdges
    ORDER BY rn
  LOOP
    SELECT network_id INTO net1
      FROM Part2_networks n
      WHERE n.node_id = rec.node_1;

    SELECT network_id INTO net2
      FROM Part2_networks n
      WHERE n.node_id = rec.node_2;

    last_node_1 := rec.node_1;
    last_node_2 := rec.node_2;

    IF net1 <> net2 THEN
      UPDATE Part2_networks
        SET network_id = LEAST(net1, net2)
        WHERE network_id = GREATEST(net1, net2);
      updated := TRUE;
      INSERT INTO Part2_last_checked (node_1, node_2, updated) VALUES (rec.node_1, rec.node_2, updated);
    END IF;
    
  END LOOP;
  
  -- RAISE NOTICE 'LAST nodes checked %, %', last_node_1, last_node_2;
END
$$;

SELECT c1.x * c2.x as result FROM Part2_last_checked lc
  JOIN Part2_Coordinates c1 ON node_1 = c1.id
  JOIN Part2_Coordinates c2 ON node_2 = c2.id
  WHERE updated = TRUE
  ORDER BY lc.id DESC
  LIMIT 1;
