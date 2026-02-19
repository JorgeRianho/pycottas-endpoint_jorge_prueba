#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -f spicepod.ontario10.yaml ]]; then
  echo "ERROR: spicepod.ontario10.yaml no existe"
  exit 1
fi

if [[ -f spicepod.yaml && ! -f spicepod.local-demo.backup.yaml ]]; then
  cp spicepod.yaml spicepod.local-demo.backup.yaml
fi

cp spicepod.ontario10.yaml spicepod.yaml

echo "spicepod.yaml actualizado con configuracion Ontario 10 DB."
echo "Siguiente paso: docker compose restart spice"
