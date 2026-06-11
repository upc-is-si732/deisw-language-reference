# Proyecto Learning Center Small 

## Creación de la red compartida de Docker

En el caso de que no exista, Crea la red donde coexistirán tus contenedores de Spring Boot, PostgreSQL, jenkins y sonarQube:

```
docker network create spring-postgres-net
```

## Creación de imagen y contenedor PosgreSql

Sigue estos comandos en tu terminal para construir y levantar todo el ecosistema de red y contenedores:

### Paso 1: Construir la imagen personalizada

Ubícate en la carpeta donde guardaste el `Dockerfile` y la carpeta `init-scripts` (que contiene los sql de la base de datos) y ejecuta la compilación:

```
docker build -t postgres-18-learning .
```

### Paso 2: Lanzar el contenedor con los parámetros específicos

Ejecuta el contenedor asociándolo a la red, mapeando exclusivamente el puerto `5435`:
	
``` 
docker run -d --name pg-learning --network spring-postgres-net -e POSTGRES_PASSWORD=postgres -p 5435:5432 postgres-18-learning
```

### paso 3: Verificar la Base de Datos y los Datos:

Ejecuta el siguiente comando en la consola o terminal para verificar que tienes acceso a la base de datos y puedes ejecutar consultas:

``` 
docker exec -it pg-learning psql -U postgres -d learningsmall -c "SELECT * FROM productos;"
``` 

### Paso 4: Verificar la Base de Datos en pgAdmin

Ejecutar pgAdmin y probar el funcionamiento.


## Creación de imagen y contenedor Learning Center Small

Sigue estos comandos en tu terminal para construir y levantar todo el ecosistema de red y contenedores:

### Paso 1: Clonar el codigo fuente desde github:

Ubicate en la carpeta donde descargarás el proyecto para ejecutar la clonación:

``` 
git clone https://github.com/upc-is-si732/learning-center-platform-small-v2520.git
``` 

### Paso 2: Construir la imagen personalizada

Ubícate en la carpeta del proyecto descargado y ejecuta la compilación:

```
docker build -t learning-center-platform-small .
```

### Paso 3: Lanzar el contenedor con los parámetros específicos

Ejecuta el contenedor asociándolo a la red, mapeando exclusivamente el puerto `8091`:
	
``` 
docker run -d --name app-learning --network spring-postgres-net -e DB_HOST=pg-learning -e DB_PORT=5432 -e DB_NAME=learningsmall -p 8091:8091 learning-center-platform-small
```

### paso 4: Verificar el funcionamiento del proyecto:

Carga el nacegador e ingresa a la siguiente dirección: http://localhost:8091/swagger-ui/index.html