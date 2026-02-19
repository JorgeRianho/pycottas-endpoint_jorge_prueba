#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -f spicepod.ontario.yaml ]]; then
  echo "ERROR: spicepod.ontario.yaml no existe"
  exit 1
fi

cp spicepod.yaml spicepod.local-demo.backup.yaml
cp spicepod.ontario.yaml spicepod.yaml

echo "spicepod.yaml actualizado con configuracion Ontario."
echo "Siguiente paso: docker compose restart spice"
