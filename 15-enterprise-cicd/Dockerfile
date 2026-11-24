FROM eclipse-temurin:17-jre

WORKDIR /app
COPY app.jar app.jar
USER 10001:10001
CMD ["java", "-cp", "app.jar", "com.example.Main"]
