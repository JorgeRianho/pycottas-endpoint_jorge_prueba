# spice-benchmark

Arranque rapido para usar [Spice.ai](https://spice.ai/) con SQL federado entre Postgres y MySQL.

## Que hace este setup

- Levanta `postgres`, `mysql` y `spice` con Docker Compose.
- Carga datos de ejemplo en `tpch`:
  - Postgres: `customers`, `orders`
  - MySQL: `customer_profiles`, `payments`
- Expone Spice en:
  - HTTP SQL API: `http://localhost:8090/v1/sql`
  - Flight SQL: `localhost:50051`

## 1) Levantar servicios

```bash
docker compose up -d
```

Ver logs de Spice:

```bash
docker compose logs -f spice
```

Cuando veas que Spice esta en estado listo, ya puedes consultar.

## 2) Consultas SQL basicas

Importante: `http://localhost:8090` en navegador puede devolver `404 Not Found`.
Eso es normal. Spice no expone una UI web en `/`; expone una API SQL en `POST /v1/sql`.

Listar datasets disponibles en Spice:

```bash
curl -sS -X POST "http://localhost:8090/v1/sql" \
  -H "Content-Type: text/plain" \
  --data-binary "SHOW TABLES;"
```

Consulta sobre Postgres:

```bash
curl -sS -X POST "http://localhost:8090/v1/sql" \
  -H "Content-Type: text/plain" \
  --data-binary "SELECT * FROM pg_orders LIMIT 5;"
```

Consulta sobre MySQL:

```bash
curl -sS -X POST "http://localhost:8090/v1/sql" \
  -H "Content-Type: text/plain" \
  --data-binary "SELECT * FROM mysql_customer_profiles LIMIT 5;"
```

## 3) SQL federado (Postgres + MySQL)

Join entre ordenes (Postgres) y perfiles (MySQL):

```bash
curl -sS -X POST "http://localhost:8090/v1/sql" \
  -H "Content-Type: text/plain" \
  --data-binary "
SELECT
  o.customer_id,
  c.customer_name,
  p.segment,
  SUM(o.total_amount) AS total_orders
FROM pg_orders o
JOIN pg_customers c ON c.customer_id = o.customer_id
JOIN mysql_customer_profiles p ON p.customer_id = o.customer_id
GROUP BY o.customer_id, c.customer_name, p.segment
ORDER BY total_orders DESC;
"
```

Cruce de montos entre ordenes (Postgres) y pagos (MySQL):

```bash
curl -sS -X POST "http://localhost:8090/v1/sql" \
  -H "Content-Type: text/plain" \
  --data-binary "
SELECT
  o.customer_id,
  SUM(o.total_amount) AS ordered,
  COALESCE(SUM(pay.amount), 0) AS paid,
  SUM(o.total_amount) - COALESCE(SUM(pay.amount), 0) AS balance
FROM pg_orders o
LEFT JOIN mysql_payments pay ON pay.customer_id = o.customer_id
GROUP BY o.customer_id
ORDER BY o.customer_id;
"
```

## 4) Re-cargar datos de init

Los scripts de `init/` se ejecutan solo cuando el volumen de DB esta vacio.

Para reiniciar desde cero:

```bash
docker compose down -v
docker compose up -d
```

## 5) Si localhost no te funciona

1. Verifica contenedores:

```bash
docker compose ps
```

Debes ver `spice` con `0.0.0.0:8090->8090/tcp`.

2. Verifica que el endpoint SQL responde:

```bash
curl -i -sS -X POST "http://localhost:8090/v1/sql" \
  -H "Content-Type: text/plain" \
  --data-binary "SELECT 1 AS ok;"
```

Respuesta esperada: `HTTP/1.1 200 OK` y `[{"ok":1}]`.

3. Si usas VM/WSL/SSH remoto, `localhost` puede no ser tu maquina host.
   Prueba con la IP del host Linux:

```bash
HOST_IP=$(hostname -I | awk '{print $1}')
curl -i -sS -X POST "http://${HOST_IP}:8090/v1/sql" \
  -H "Content-Type: text/plain" \
  --data-binary "SELECT 1 AS ok;"
```

## Como seguir con tu benchmark real

1. Sustituye tablas de ejemplo por tus tablas benchmark reales en `spicepod.yaml`.
2. Mantén el patron: un dataset por tabla/fuente (`postgres:...`, `mysql:...`).
3. Ejecuta joins y agregaciones directamente en Spice usando SQL estandar.

## 6) Cliente SQL: DataGrip

Spice expone Flight SQL en `localhost:50051` y DataGrip se conecta via JDBC.

1. Descarga el driver JDBC de Arrow Flight SQL (`flight-sql-jdbc-driver-<version>.jar`).
2. En DataGrip: `+` -> `Driver`.
3. Agrega el JAR descargado en `Driver Files`.
4. Clase del driver: `org.apache.arrow.driver.jdbc.ArrowFlightJdbcDriver`.
5. URL template:

```text
jdbc:arrow-flight-sql://{host}:{port}?useEncryption=false&disableCertificateVerification=true
```

6. Crea un `Data Source` nuevo con ese driver:
   - Host: `localhost`
   - Port: `50051`
   - Authentication: `No auth`
7. `Test Connection` y luego abre `Query Console`.

## 7) Cliente SQL: DBeaver

1. `Database` -> `Driver Manager` -> `New`.
2. En `Libraries`, agrega `flight-sql-jdbc-driver-<version>.jar`.
3. Configura:
   - Driver Name: `Apache Arrow Flight SQL`
   - URL template:

```text
jdbc:arrow-flight-sql://{host}:{port}?useEncryption=false&disableCertificateVerification=true
```

4. Driver Type: `SQLite` (segun docs de Spice para DBeaver).
5. Authentication: `No authentication`.
6. Crea nueva conexion con Host `localhost`, Port `50051`, y prueba conexion.

## 8) Verificacion rapida antes del cliente SQL

Ejecuta:

```bash
bash scripts/test_spice_endpoints.sh
```

Si todo esta bien, veras:
- HTTP SQL OK (`/v1/sql`)
- Puerto Flight SQL abierto (`50051`)

## 9) Ejecutar SQL desde web (sin DataGrip)

Si te aparece "no response" en extensiones, usa esta web local incluida en el repo.

1. Arranca Spice:

```bash
docker compose up -d
```

2. Arranca servidor web local para la UI:

```bash
bash scripts/run_sql_web_ui.sh
```

3. Abre en navegador:

```text
http://localhost:8088/sql-web-ui.html
```

4. En la caja SQL prueba primero:

```sql
SELECT 1 AS ok;
```

5. Luego:

```sql
SHOW TABLES;
```

Nota: no abras `http://localhost:8090/` esperando una pagina web; es API y en `/` devuelve 404.

### Nota importante (Error `Failed to fetch`)

Si aparece `TypeError: Failed to fetch`, era CORS del navegador.
La version actual de `scripts/run_sql_web_ui.sh` ya levanta un proxy local `/sql` para evitarlo.

Arranque correcto:

```bash
docker compose up -d
bash scripts/run_sql_web_ui.sh
```

Luego abre:

```text
http://localhost:8088/sql-web-ui.html
```

## 10) Conectar Spice al benchmark real Ontario (MySQL + PostgreSQL)

Este repo ya incluye una configuracion lista en `spicepod.ontario.yaml` para 4 tablas base:

- MySQL `affymetrix.Probeset_main` (puerto `9000`)
- MySQL `chebi.Compound_main` (puerto `9001`)
- PostgreSQL `public.probeset_main` en DB `affymetrix` (puerto `9100`)
- PostgreSQL `public.compound_main` en DB `chebi` (puerto `9101`)

### 10.1 Levantar solo las BDs necesarias de Ontario

Desde `Ontario-SEAData2020/datasources/mysql`:

```bash
# MySQLs benchmark
 docker compose up -d mysql_affymetrix_idx mysql_chebi_idx

# PostgreSQL benchmark
 docker compose -f docker-compose-p.yml up -d postgres_affymetrix_idx postgres_chebi_idx
```

### 10.2 Cambiar Spice al spicepod de Ontario

Desde `spice-benchmark`:

```bash
bash scripts/use_ontario_spicepod.sh
docker compose restart spice
```

Verifica que cargan datasets:

```bash
docker compose logs -f spice
```

Debes ver los 4 datasets `mysql_*` y `pg_*` registrados.

### 10.3 Ejecutar queries benchmark

SQLs listas en:

- `queries/ontario_federated.sql`

Puedes pegarlas en la Web UI (`http://localhost:8088/sql-web-ui.html`) o por curl:

```bash
curl -sS -X POST "http://localhost:8090/v1/sql" \
  -H "Content-Type: text/plain" \
  --data-binary "SELECT COUNT(*) FROM mysql_affymetrix_probeset_main;"
```

### 10.4 Volver al demo local

```bash
bash scripts/use_local_demo_spicepod.sh
docker compose restart spice
```

## 11) Spice como capa unica para las 10 BDs Ontario

### 11.1 Levantar las 10 BDs MySQL de Ontario

```bash
cd /home/jorge/proyectos/git/Ontario-SEAData2020/datasources/mysql
docker compose up -d
```

### 11.2 Activar spicepod de 10 BDs

```bash
cd /home/jorge/proyectos/git/spice-benchmark
bash scripts/use_ontario10_spicepod.sh
docker compose restart spice
```

### 11.3 Verificar

```bash
curl -sS -X POST "http://localhost:8090/v1/sql" \
  -H "Content-Type: text/plain" \
  --data-binary "SHOW TABLES;"
```

Queries de prueba en:
- `queries/ontario10_smoke.sql`

### 11.4 Sobre Ontop encima de Spice

Ontop se conecta a motores SQL con dialecto soportado (MySQL/PostgreSQL/Trino/etc.).
Spice expone SQL por Flight SQL/JDBC, pero no como servidor MySQL/PostgreSQL nativo.
Por eso, usar Ontop *directamente* sobre Spice no es la opcion mas estable.

Patrones recomendados:
1. Ontop sobre las BDs originales (como ya tienes en `ontop_*`) y usar Ontario para federar SPARQL.
2. Spice como capa SQL federada para analitica SQL.
3. Si necesitas Ontop sobre una sola fuente federada, materializa primero resultados en PostgreSQL/MySQL y conecta Ontop a esa BD.

## 12) Ontop sobre datos materializados desde Spice

Este flujo crea una BD PostgreSQL `materialized` alimentada desde Spice y monta Ontop sobre esa BD.

### 12.1 Arranque automatizado

```bash
cd /home/jorge/proyectos/git/spice-benchmark
bash materialized/scripts/start_ontop_over_spice.sh
```

Esto hace:
1. Activa Spice con el `spicepod` de 10 BDs (`spicepod.ontario10.yaml`).
2. Extrae desde Spice el join `drugbank.drugs_target` + `drugbank.targets_main`.
3. Carga el resultado en PostgreSQL (`materialized.drug_target_materialized`).
4. Levanta Ontop en `http://localhost:18084/`.

### 12.2 Probar SPARQL

Endpoint web:
- `http://localhost:18084/`

Endpoint HTTP:
- `http://localhost:18084/sparql`

Consulta de conteo:

- Archivo: `materialized/mappings/count.sparql`

Consulta tipo Q2:

- Archivo: `materialized/mappings/q2_like.sparql`

### 12.3 Re-materializar tras cambios en Spice

```bash
cd /home/jorge/proyectos/git/spice-benchmark
python3 materialized/scripts/materialize_from_spice.py materialized/data/drug_target_materialized.tsv
cd materialized
docker compose exec -T postgres_materialized psql -U postgres -d materialized -c "TRUNCATE TABLE drug_target_materialized;"
docker compose exec -T postgres_materialized psql -U postgres -d materialized -c "\\copy drug_target_materialized (drug_id, target_id, target_label, chromosome_location) FROM '/data/drug_target_materialized.tsv' WITH (FORMAT csv, DELIMITER E'\\t', HEADER true);"
```
