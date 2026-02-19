#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
MAT_DIR="$ROOT_DIR/materialized"

# 1) Ensure Spice runtime is running in 10-DB mode
bash "$ROOT_DIR/scripts/use_ontario10_spicepod.sh"
docker compose -f "$ROOT_DIR/docker-compose.yml" up -d spice

# 2) Start materialized postgres
cd "$MAT_DIR"
docker compose up -d postgres_materialized

# 3) Extract from Spice into TSV
python3 "$MAT_DIR/scripts/materialize_from_spice.py" "$MAT_DIR/data/drug_target_materialized.tsv"

# 4) Load TSV into postgres_materialized
docker compose exec -T postgres_materialized psql -U postgres -d materialized <<'SQL'
CREATE TABLE IF NOT EXISTS drug_target_materialized (
  drug_id TEXT,
  target_id TEXT,
  target_label TEXT,
  chromosome_location TEXT
);
TRUNCATE TABLE drug_target_materialized;
\copy drug_target_materialized (drug_id, target_id, target_label, chromosome_location) FROM '/data/drug_target_materialized.tsv' WITH (FORMAT csv, DELIMITER E'\t', HEADER true);
SQL

# 5) Start ontop over materialized table
docker compose up -d --build ontop_materialized

echo
echo "Listo. Endpoint Ontop sobre Spice materializado:"
echo "  http://localhost:18084/"
echo "SPARQL endpoint:"
echo "  http://localhost:18084/sparql"
