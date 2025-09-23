# Karate Framework Project

Mayor información sobre Karate lo encuentras en los siguientes enlaces:
- https://github.com/karatelabs
- https://github.com/karatelabs/karate/wiki/Get-Started:-Maven-and-Gradle
- https://github.com/karatelabs/karate#quickstart
- https://www.karatelabs.io/
- https://karatelabs.github.io/karate/

## Getting Started

### Maven

```xml
<dependency>
    <groupId>io.karatelabs</groupId>
    <artifactId>karate-junit5</artifactId>
    <version>1.5.1</version>
    <scope>test</scope>
</dependency>
```

### Quickstart

Maven Command para crear un project karate

```bash
mvn archetype:generate \
-DarchetypeGroupId=io.karatelabs \
-DarchetypeArtifactId=karate-archetype \
-DarchetypeVersion=1.5.1 \
-DgroupId=pe.edu.upc \
-DartifactId=learning-center-test
```

### IntelliJ IDEA

Crear un __new project__ tipo `maven Archetype` con la siguiente información:

- __Name__: `deisw-learning-center-test`
- Agregar un nuevo `Archetype` con la siguiente información:
    - GroupId: `io.karatelabs`
    - ArtifactId: `karate-archetype`
    - Versión: `1.5.1`
- En Advanced Setting:
    - GroupId: `pe.edu.upc`
    - ArtifactId: `deisw-learning-center-test`

Para ejecutar los Test ejecute el siguiente commando:
```bash
mvn clean test
```

### Desarrollo

Cargue el Swagger UI de su proyect para realizar los test: http://localhost:8091/swagger-ui/index.html

