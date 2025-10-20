from rdflib_endpoint.__main__ import run_serve

# Archivos de entrada RDF (por ejemplo, TTLs generados por Morph-KGC)
files = ["mapping.ttl", "data.ttl"]

# Inicia el endpoint en localhost:8000 con Oxigraph
run_serve(files=files, host="localhost", port=8000, store="Oxigraph", enable_update=False)

