#!/usr/bin/env bash
set -euo pipefail

SPICE_HTTP_HOST="${SPICE_HTTP_HOST:-localhost}"
SPICE_HTTP_PORT="${SPICE_HTTP_PORT:-8090}"
SPICE_FLIGHT_HOST="${SPICE_FLIGHT_HOST:-localhost}"
SPICE_FLIGHT_PORT="${SPICE_FLIGHT_PORT:-50051}"

echo "[1/2] Probando HTTP SQL en http://${SPICE_HTTP_HOST}:${SPICE_HTTP_PORT}/v1/sql"
HTTP_OUT=$(curl -sS -X POST "http://${SPICE_HTTP_HOST}:${SPICE_HTTP_PORT}/v1/sql" \
  -H "Content-Type: text/plain" \
  --data-binary "SELECT 1 AS ok;")

if [[ "${HTTP_OUT}" != *'"ok":1'* ]]; then
  echo "ERROR: respuesta inesperada de HTTP SQL: ${HTTP_OUT}"
  exit 1
fi

echo "OK: HTTP SQL responde correctamente: ${HTTP_OUT}"

echo "[2/2] Probando puerto Flight SQL ${SPICE_FLIGHT_HOST}:${SPICE_FLIGHT_PORT}"
if command -v nc >/dev/null 2>&1; then
  if nc -z "${SPICE_FLIGHT_HOST}" "${SPICE_FLIGHT_PORT}"; then
    echo "OK: puerto Flight SQL abierto"
  else
    echo "ERROR: no se puede abrir ${SPICE_FLIGHT_HOST}:${SPICE_FLIGHT_PORT}"
    exit 1
  fi
else
  echo "WARN: 'nc' no esta instalado; omito check de puerto Flight SQL"
fi

echo "Listo. Puedes conectar DataGrip/DBeaver al endpoint Flight SQL."
