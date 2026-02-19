FROM eclipse-temurin:17-jdk

WORKDIR /app

COPY Ontario-SEAData2020/datasources/mysql/ontop/ontop-cli-5.4.0 /app/ontop
COPY Ontario-SEAData2020/datasources/mysql/jdbc/postgresql-42.7.3.jar /app/ontop/jdbc/

ENTRYPOINT ["/app/ontop/ontop"]
CMD ["endpoint", \
     "--ontology=/app/ontology.owl", \
     "--mapping=/app/mapping.ttl", \
     "--properties=/app/ontop.properties", \
     "--port=8080"]
