#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -f spicepod.local-demo.backup.yaml ]]; then
  echo "ERROR: spicepod.local-demo.backup.yaml no existe."
  echo "Primero ejecuta scripts/use_ontario_spicepod.sh para crear el backup."
  exit 1
fi

cp spicepod.local-demo.backup.yaml spicepod.yaml

echo "spicepod.yaml restaurado al demo local."
echo "Siguiente paso: docker compose restart spice"
