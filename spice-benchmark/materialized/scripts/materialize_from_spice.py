#!/usr/bin/env python3
import csv
import json
import sys
import urllib.request

SPICE_URL = "http://localhost:8090/v1/sql"
SQL = """
SELECT
  dt.drugs AS drug_id,
  dt.target AS target_id,
  tm.label AS target_label,
  tm.chromosomeLocation AS chromosome_location
FROM mysql_drugbank_drugs_target dt
JOIN mysql_drugbank_targets_main tm ON dt.target = tm.targets
""".strip()


def fetch_rows():
    req = urllib.request.Request(
        SPICE_URL,
        data=SQL.encode("utf-8"),
        method="POST",
        headers={"Content-Type": "text/plain"},
    )
    with urllib.request.urlopen(req, timeout=120) as resp:
        payload = resp.read().decode("utf-8")
    rows = json.loads(payload)
    if not isinstance(rows, list):
        raise RuntimeError(f"Respuesta inesperada de Spice: {type(rows)}")
    return rows


def to_str(v):
    return "" if v is None else str(v)


def main(out_path: str):
    rows = fetch_rows()
    fields = ["drug_id", "target_id", "target_label", "chromosome_location"]
    with open(out_path, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fields, delimiter="\t")
        w.writeheader()
        for r in rows:
            w.writerow({k: to_str(r.get(k)) for k in fields})
    print(f"rows={len(rows)}")
    print(f"file={out_path}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: materialize_from_spice.py <output_tsv>")
        sys.exit(1)
    main(sys.argv[1])
