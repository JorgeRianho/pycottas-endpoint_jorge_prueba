-- Q1: Sanity check de disponibilidad por fuente
SELECT 'mysql_affymetrix_probeset_main' AS dataset, COUNT(*) AS n FROM mysql_affymetrix_probeset_main
UNION ALL
SELECT 'pg_affymetrix_probeset_main' AS dataset, COUNT(*) AS n FROM pg_affymetrix_probeset_main
UNION ALL
SELECT 'mysql_chebi_compound_main' AS dataset, COUNT(*) AS n FROM mysql_chebi_compound_main
UNION ALL
SELECT 'pg_chebi_compound_main' AS dataset, COUNT(*) AS n FROM pg_chebi_compound_main;

-- Q2: Join federado (mismo dominio Affymetrix entre MySQL y Postgres)
SELECT
  COALESCE(m.probe_set_id, p.probe_set_id) AS probe_set_id,
  m.probeset AS mysql_probeset,
  p.probeset AS pg_probeset
FROM mysql_affymetrix_probeset_main m
JOIN pg_affymetrix_probeset_main p ON m.probeset = p.probeset
LIMIT 100;

-- Q3: Join federado (mismo dominio ChEBI entre MySQL y Postgres)
SELECT
  COALESCE(m.compound, p.compound) AS compound,
  m.label AS mysql_label,
  p.label AS pg_label
FROM mysql_chebi_compound_main m
JOIN pg_chebi_compound_main p ON m.compound = p.compound
LIMIT 100;

-- Q4: Diferencias de cobertura entre motores (Affymetrix)
SELECT
  SUM(CASE WHEN m.probeset IS NOT NULL AND p.probeset IS NOT NULL THEN 1 ELSE 0 END) AS both,
  SUM(CASE WHEN m.probeset IS NOT NULL AND p.probeset IS NULL THEN 1 ELSE 0 END) AS only_mysql,
  SUM(CASE WHEN m.probeset IS NULL AND p.probeset IS NOT NULL THEN 1 ELSE 0 END) AS only_postgres
FROM mysql_affymetrix_probeset_main m
FULL OUTER JOIN pg_affymetrix_probeset_main p ON m.probeset = p.probeset;

-- Q5: Agregacion comparativa por prefijo (ChEBI)
SELECT
  LEFT(COALESCE(m.compound, p.compound), 20) AS key_prefix,
  COUNT(*) AS n
FROM mysql_chebi_compound_main m
JOIN pg_chebi_compound_main p ON m.compound = p.compound
GROUP BY LEFT(COALESCE(m.compound, p.compound), 20)
ORDER BY n DESC
LIMIT 20;
