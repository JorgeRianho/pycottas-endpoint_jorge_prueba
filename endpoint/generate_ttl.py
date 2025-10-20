import morph_kgc

# Ejecutar la materialización utilizando el archivo de configuración
graph = morph_kgc.materialize("config.ini")

# Guardar el grafo RDF en formato Turtle
with open("data.ttl", "w", encoding="utf-8") as f:
    f.write(graph.serialize(format="turtle"))

print("✅ RDF generado correctamente en data.ttl")

