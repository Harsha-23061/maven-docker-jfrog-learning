FROM eclipse-temurin:17-jre-noble@sha256:ad806840ae514b83d3d8e3a00a5c1b7302fb0a6ae02bbbaf8a8bf1ffdf5367c6

WORKDIR /app
COPY app.jar app.jar
USER 10001:10001
CMD ["java", "-cp", "app.jar", "com.example.Main"]
