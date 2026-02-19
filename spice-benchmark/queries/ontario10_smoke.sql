-- Smoke test: verify datasets from 10 DBs are visible
SHOW TABLES;

SELECT COUNT(*) AS n FROM mysql_affymetrix_probeset_main;
SELECT COUNT(*) AS n FROM mysql_chebi_compound_main;
SELECT COUNT(*) AS n FROM mysql_dailymed_drugs_main;
SELECT COUNT(*) AS n FROM mysql_diseasome_diseases_main;
SELECT COUNT(*) AS n FROM mysql_drugbank_drugs_main;
SELECT COUNT(*) AS n FROM mysql_kegg_compound_main;
SELECT COUNT(*) AS n FROM mysql_linkedct_agency_main;
SELECT COUNT(*) AS n FROM mysql_medicare_drugs_main;
SELECT COUNT(*) AS n FROM mysql_sider_drugs_main;
SELECT COUNT(*) AS n FROM mysql_tcga_aliquot_main;

-- Drugbank intra-DB join in Spice (useful for equivalent of Q2 pattern)
SELECT dt.drugs AS drug_id, tm.label AS target_label, tm.chromosomeLocation AS loc
FROM mysql_drugbank_drugs_target dt
JOIN mysql_drugbank_targets_main tm ON CAST(dt.target AS CHAR) = CAST(tm.targets AS CHAR)
LIMIT 200;
