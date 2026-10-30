# ---------- Stage 1: build the jar ----------
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# Copy only pom.xml first so the dependency layer is cached
COPY pom.xml .
RUN mvn -B dependency:go-offline

# Now copy the source and build
COPY src ./src
RUN mvn -B clean package -DskipTests

# ---------- Stage 2: slim runtime ----------
FROM eclipse-temurin:21-jre-alpine

# Run as a non-root user
RUN addgroup -S spring && adduser -S spring -G spring
WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

USER spring
ENV SERVER_PORT=8080
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
