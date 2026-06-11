# Jenkins y SonarQube en Docker

## Creación de la red compartida de Docker

En el caso de que no exista, Crea la red donde coexistirán tus contenedores de Spring Boot, PostgreSQL, jenkins y sonarQube:

```
docker network create spring-postgres-net
```

## Creación de imagen y contenedor de Jenkins

Sigue estos comandos en tu terminal para construir y levantar todo el ecosistema de red y contenedores:


### Paso 1: Construir la imagen personalizada

Ubícate en la carpeta donde guardaste el `Dockerfile` y el `plugins.txt` y ejecuta la compilación:

```
docker build --platform linux/amd64 -t jenkins-ci-cd:2026.final .
```

### Paso 2: Lanzar el contenedor con los parámetros específicos

Ejecuta el contenedor asociándolo a la red, mapeando exclusivamente el puerto `9089` (modificando el comportamiento interno de Jenkins mediante `JENKINS_OPTS`) y asegurando la persistencia de datos en un volumen:
	
``` 
docker run -d --name jenkins-master --platform linux/amd64 --user root --network spring-postgres-net -p 9089:9089 -p 50000:50000 -v /var/run/docker.sock:/var/run/docker.sock -v jenkins_data:/var/jenkins_home -e JENKINS_OPTS="--httpPort=9089" jenkins-ci-cd:2026.final
```

### Paso 3: Obtener la credencial inicial de acceso

Espera unos segundos a que el servidor inicialice por completo y recupera la clave temporal de administrador:

```
docker logs jenkins-master
```

### Paso 4: cargar el Jenkins
	
Ingresa a la siguiente dirección en el navegador para ingresar a Jenkisn e inicia con la instalación y configuración inicial de Jenkins:

```
http://localhost:9089/
```

Configura el Jenkins de acuerdo a tus necesidades y manuales proporcionados.


## SonarQube

### Paso 1: Lanzar el contenedor con los parámetros específicos

Ejecuta el siguiente comando para lanzar el contenedor de SonarQube:
	
``` 
# https://hub.docker.com/_/sonarqube/tags?name=lts-community
docker run -d --name sonarqube-server --network spring-postgres-net -p 9000:9000 -v sonarqube_data:/opt/sonarqube/data -v sonarqube_extensions:/opt/sonarqube/extensions -v sonarqube_logs:/opt/sonarqube/logs sonarqube:lts-community
```

Ingresa a la siguiente dirección en el navegador para ingresar a sonarQube e inicia con la configuración inicial de sonarQube:

```
http://localhost:9000/
```

Recuerda que podras acceder a sonarQube desde otro contenedor utilizando la siguiente dirección:

```
http://sonarqube-server:9000
```

## Integración de Jenkins con SonarQube

A continuación realizaremos la configuracion del Token y Webhook en sonarQube y Jenkins.

### Paso 1: Generar el Token de Seguridad en SonarQube

Para que Jenkins tenga permisos de enviar los reportes de análisis, necesita autenticarse mediante un token.
- Inicia sesión y/o accede a la página de SonarQube: http://localhost:9000.
- Haz clic en el ícono de tu usuario en la esquina superior derecha y selecciona `My Account` (Mi Cuenta).
- Ve a la pestaña `Security` (Seguridad).
- En la sección `Generate Tokens`:
  - `Name`: Escribe un nombre descriptivo: `jenkins-token`.
  - `Type`: Selecciona `User Token` (o Global Analysis Token).
  - `Expires in`: Elige la expiración que prefieras: `No expiration` (para entornos de desarrollo).
- Haz clic en el botón `Generate`.
- Copia el token generado inmediatamente (es una cadena alfanumérica larga). No podrás volver a verlo.

### Paso 2: Registrar el Token en Jenkins

Ahora guardaremos el token en el almacén de credenciales seguras de Jenkins.
- Inicia sesión y/o accede a la página de Jenkins http://localhost:9089.
- Ve a Administrar Jenkins `Manage Jenkins` ➔ `Credentials` (Credenciales).
- Haz clic en el dominio `global` y luego en `Add Credentials` (Añadir credenciales).
- Configura los siguientes campos:
  - `Kind`: Selecciona `Secret text`.
  - `Scope`: Selecciona `Global`.
  - `Secret`: Pega aquí el token que copiaste de SonarQube en el `Paso 1`.
  - `ID`: Escribe un identificador único: `sonarqube-token-id`.
  - `Description`: Una breve descripción: `Token de autenticación para SonarQube`.
- Haz clic en `Create`.

### Paso 3: Configurar el Servidor SonarQube en Jenkins

En este paso le diremos al plugin de SonarQube: dónde escuchar y qué credencial usar.
- Ve a Administrar Jenkins (`Manage Jenkins`) ➔ `System` (Configuración del Sistema).
- Desplázate hacia abajo hasta encontrar la sección `SonarQube servers`.
- Haz clic en `Add SonarQube`.
- Configurar las propiedades del servidor:
  - `Name`: Asígnale un nombre clave. Este nombre es el que usarás en tus scripts Jenkinsfile: `MiSonarServer`.
  - `Server URL`: Aquí aprovechamos que están en la misma red de Docker. Usa la URL interna del contenedor:
`http://sonarqube-server:9000`
  - `Server authentication token`: Selecciona de la lista desplegable la credencial que creaste en el paso anterior (`sonarqube-token-id`).
- Haz clic en `Apply` y luego en `Save`.

### Paso 4:  Configuración de Webhook en SonarQube

#### Fundamento:

Para que la integración entre Jenkins y SonarQube funcione de manera bidireccional y eficiente, es fundamental configurar un Webhook.

El Webhook permite que, una vez que SonarQube termine de procesar el análisis estático del código (lo cual ocurre de forma asíncrona en su propio contenedor), le envíe una notificación inmediata a Jenkins con el resultado del Quality Gate (aprobado o fallido). De esta manera, Jenkins sabe exactamente cuándo continuar o detener el pipeline sin quedarse congelado en un bucle de espera indefinido.
Dado que ambos contenedores coexisten en la red de Docker spring-postgres-net, la comunicación se realizará de manera interna utilizando sus nombres de contenedor. A continuación, tienes el paso a paso detallado para configurarlo en ambas plataformas:

#### Procedimiento:

En este paso, le indicaremos a SonarQube a qué dirección interna debe enviar la notificación HTTP en cuanto termine de evaluar un proyecto.

- Inicia sesión y/o accede a la página de SonarQube: http://localhost:9000.
- En la barra de navegación superior, haz clic en el menú `Administration` (Administración global).
- En el menú desplegable que aparece justo debajo, selecciona `Configuration` y luego haz clic en `Webhooks`.
- En la esquina superior derecha de la sección, haz clic en el botón `Create` (Crear).
- Se abrirá un formulario flotante. Configura los siguientes campos con estos valores exactos:
  - `Name`: Asigna un nombre identificativo para el webhook: `Jenkins-CI-Webhook`
  - `URL`: Aquí debes colocar la URL del endpoint del plugin de SonarQube dentro de Jenkins. Como Jenkins está en la misma red de Docker bajo el nombre `jenkins-master` y configuramos su puerto en el `9089`, la estructura interna obligatoria es: `http://jenkins-master:9089/sonarqube-webhook/`
  - `Secret`: Déjalo en blanco (a menos que hayas configurado una clave de firma avanzada en Jenkins).
- Haz clic en el botón `Create` en la parte inferior del formulario.

### Paso 5: Habilitar el Quality Gate en Jenkins

No necesitas realizar ninguna acción adicional en la interfaz gráfica de Jenkins para el Webhook, pero sí debes estructurar correctamente tu archivo `Jenkinsfile` utilizando el paso `waitForQualityGate()`.

### Paso 6: Verificar que el Webhook está funcionando correctamente

Una vez que guardes el pipeline y ejecutes un nuevo Job en Jenkins, puedes monitorear el éxito de la comunicación desde el panel de SonarQube:

- Inicia sesión y/o accede a la página de SonarQube: http://localhost:9000 
- Ingresa a la sección `Administration` ➔ `Configuration` ➔` Webhooks`.
- Al lado del Webhook que creaste (`Jenkins-CI-Webhook`), verás una columna llamada `Show Delivery Log` donde podrás visualizar el estado.

### Paso 7: Ejecutar Job en Jenkins

Crear un Job pipeline apuntando el proyecto ubicado en la siguiente dirección git:

```
https://github.com/upc-is-si732/learning-center-platform-small-v2520.git
```

Ejecuta el Job creado en Jenkins.




