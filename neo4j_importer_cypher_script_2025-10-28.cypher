// NOTE: The following script syntax is valid for database version 5.0 and above.

:param {
  // Define the file path root and the individual file names required for loading.
  // https://neo4j.com/docs/operations-manual/current/configuration/file-locations/
  file_path_root: 'file:///', // Change this to the folder your script can access the files at.
  file_0: 'actors.csv',
  file_1: 'movies.csv',
  file_2: 'people.csv'
};

// CONSTRAINT creation
// -------------------
//
// Create node uniqueness constraints, ensuring no duplicates for the given node label and ID property exist in the database. This also ensures no duplicates are introduced in future.
//
CREATE CONSTRAINT `personId_actors_uniq` IF NOT EXISTS
FOR (n: `actors`)
REQUIRE (n.`personId`) IS UNIQUE;
CREATE CONSTRAINT `movieId_movies_uniq` IF NOT EXISTS
FOR (n: `movies`)
REQUIRE (n.`movieId`) IS UNIQUE;
CREATE CONSTRAINT `personId_people_uniq` IF NOT EXISTS
FOR (n: `people`)
REQUIRE (n.`personId`) IS UNIQUE;

:param {
  idsToSkip: []
};

// NODE load
// ---------
//
// Load nodes in batches, one node label at a time. Nodes will be created using a MERGE statement to ensure a node with the same label and ID property remains unique. Pre-existing nodes found by a MERGE statement will have their other properties set to the latest values encountered in a load file.
//
// NOTE: Any nodes with IDs in the 'idsToSkip' list parameter will not be loaded.
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row
WHERE NOT row.`personId` IN $idsToSkip AND NOT toInteger(trim(row.`personId`)) IS NULL
CALL (row) {
  MERGE (n: `actors` { `personId`: toInteger(trim(row.`personId`)) })
  SET n.`personId` = toInteger(trim(row.`personId`))
  SET n.`characters` = row.`characters`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_1) AS row
WITH row
WHERE NOT row.`movieId` IN $idsToSkip AND NOT toInteger(trim(row.`movieId`)) IS NULL
CALL (row) {
  MERGE (n: `movies` { `movieId`: toInteger(trim(row.`movieId`)) })
  SET n.`movieId` = toInteger(trim(row.`movieId`))
  SET n.`title` = row.`title`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_2) AS row
WITH row
WHERE NOT row.`personId` IN $idsToSkip AND NOT toInteger(trim(row.`personId`)) IS NULL
CALL (row) {
  MERGE (n: `people` { `personId`: toInteger(trim(row.`personId`)) })
  SET n.`personId` = toInteger(trim(row.`personId`))
  SET n.`name` = row.`name`
} IN TRANSACTIONS OF 10000 ROWS;


// RELATIONSHIP load
// -----------------
//
// Load relationships in batches, one relationship type at a time. Relationships are created using a MERGE statement, meaning only one relationship of a given type will ever be created between a pair of nodes.
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_1) AS row
WITH row 
CALL (row) {
  MATCH (source: `actors` { `personId`: toInteger(trim(row.`personId`)) })
  MATCH (target: `movies` { `movieId`: toInteger(trim(row.`movieId`)) })
  MERGE (source)-[r: `acted_in`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_2) AS row
WITH row 
CALL (row) {
  MATCH (source: `people` { `personId`: toInteger(trim(row.`personId`)) })
  MATCH (target: `actors` { `personId`: toInteger(trim(row.`personId`)) })
  MERGE (source)-[r: `acted_as`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;
