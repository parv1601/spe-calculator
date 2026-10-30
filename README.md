# Calculator REST API: CI/CD Pipeline

A Spring Boot calculator service with an automated pipeline:
GitHub → Jenkins → Docker Hub → Docker Compose (Nginx + API).

CSE 816 Software Production Engineering, Mini-Project.

## Stack
Java 21, Spring Boot, Maven, JUnit 5, Docker, Docker Compose, Nginx, Jenkins.

## API

| Operation | Endpoint |
|---|---|
| Add | `GET /api/v1/add?a=2&b=3` |
| Subtract | `GET /api/v1/subtract?a=5&b=2` |
| Multiply | `GET /api/v1/multiply?a=4&b=3` |
| Divide | `GET /api/v1/divide?a=6&b=3` |
| Health | `GET /actuator/health` |

Success response:
```json
{ "operation": "add", "a": 2.0, "b": 3.0, "result": 5.0 }
```

Invalid or missing parameters, and division by zero, return HTTP 400:
```json
{ "status": 400, "error": "Bad Request", "message": "Cannot divide by zero" }
```

## Build, test, run

```bash
./mvnw clean package        # build the executable JAR
./mvnw test                 # run unit and MockMvc integration tests
./mvnw spring-boot:run      # run locally (http://localhost:8081)
```

## Run with Docker

```bash
docker build -t calculator:local .
docker run --rm -p 8081:8080 calculator:local
```

## Run the full stack with Docker Compose

```bash
docker compose up -d --build --wait
curl "http://localhost:8082/api/v1/add?a=2&b=3"
docker compose down
```

Nginx listens on port 8082 and proxies to the calculator container,
which is only reachable inside the Compose network.

## CI/CD pipeline

The `Jenkinsfile` defines these stages: Checkout, Build, Test, Docker Build,
Push, Deploy. Jenkins polls GitHub every 2 minutes. The image is pushed to
Docker Hub as `parrvv/calculator:<build-number>` and `latest`, and the stack
is deployed with `docker compose up -d --wait`. Build status is emailed.
Docker Hub credentials are stored in the Jenkins credentials store
(ID `dockerhub-creds`), never in the repository.

## Repository layout
src/main/java/... Spring Boot application
src/test/java/... JUnit tests
pom.xml Maven build
Dockerfile multi-stage build, non-root runtime
docker-compose.yml API + Nginx proxy, healthcheck
nginx/ reverse proxy config
Jenkinsfile declarative pipeline
Docker Hub image: https://hub.docker.com/r/parrvv/calculator

_Pipeline verified: a push to main triggers Jenkins automatically._
