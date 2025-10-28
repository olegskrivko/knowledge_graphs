# Movie Knowledge Graph (Neo4j)

## Overview

This project builds a semantic knowledge graph using Neo4j to represent relationships between **movies**, **actors**, and **people**. It integrates data from three CSV files:

- `actors.csv`: Links between people and movies via character roles
- `movies.csv`: Metadata about films including title, genres, release year, and cast
- `people.csv`: Biographical data about individuals (e.g., actors, directors)

The graph enables rich querying of cast, crew, character roles, genres, and temporal data.

---

## Data Model

### Node Types

| Label     | Description                          | Key Properties                          |
|-----------|--------------------------------------|------------------------------------------|
| `people`  | Real individuals (e.g., actors)      | `personId`, `name`, `birthYear`, `deathYear` |
| `actors`  | Role instances (person + character)  | `personId`, `movieId`, `characters`      |
| `movies`  | Films                                | `movieId`, `title`, `releaseYear`, `avgVote`, `tagline`, `genres` |

---

### Relationship Types

| Relationship     | From       | To        | Description                              |
|------------------|------------|-----------|------------------------------------------|
| `acted_as`       | `people`   | `actors`  | Links real person to their acting role   |
| `acted_in`       | `actors`   | `movies`  | Links role to the movie they appear in   |

---
