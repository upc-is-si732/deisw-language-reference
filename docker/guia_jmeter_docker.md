# Guía Paso a Paso: Despliegue de Apache JMeter en Docker con Alpine Linux y Eclipse Temurin JDK 25

Esta guía detalla el proceso completo para configurar, construir y ejecutar un entorno optimizado de pruebas de carga con **Apache JMeter 5.6.3** sobre una imagen ultra ligera de **Alpine Linux** con **Eclipse Temurin JDK 25 (LTS)**.

---

## 1. Requisitos Previos

Antes de comenzar, asegúrate de contar con los siguientes elementos instalados en tu sistema local:

* [Docker Engine](https://docs.docker.com/get-docker/) (v20.10 o superior)
* [Docker Compose](https://docs.docker.com/compose/install/) (v2.0 o superior)
* Un plan de pruebas de JMeter (`.jmx`) previo o utilizar el script de prueba básico proporcionado en esta guía.

---

## 2. Estructura del Proyecto

Crea un directorio de trabajo en tu máquina local con la siguiente estructura interna:

```text
jmeter-java25-docker/
├── Dockerfile
├── docker-compose.yml
├── test_plan.jmx
└── results/
```

Comando rápido para crear la estructura (en Linux/macOS o Bash):

```bash
mkdir -p jmeter-java25-docker/results
cd jmeter-java25-docker
```

---

## 3. Configuración del Dockerfile

Crea un archivo llamado `Dockerfile` en la raíz de la carpeta. Este archivo compila la imagen utilizando la distribución ligera **Alpine Linux** con **Eclipse Temurin JDK 25**.

```dockerfile
# Imagen Base: Alpine Linux con Eclipse Temurin JDK 25
FROM eclipse-temurin:25-jdk-alpine

# Definición de la versión de Apache JMeter
ARG JMETER_VERSION=5.6.3

# Instalar utilidades necesarias del sistema operativo
RUN apk add --no-cache \
    wget \
    curl \
    bash \
    tar \
    tzdata

# Descargar e instalar Apache JMeter
RUN wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz && \
    tar -xzf apache-jmeter-${JMETER_VERSION}.tgz -C /opt/ && \
    rm apache-jmeter-${JMETER_VERSION}.tgz

# Definir variables de entorno principales
ENV JMETER_HOME=/opt/apache-jmeter-${JMETER_VERSION}
ENV PATH=$JMETER_HOME/bin:$PATH

# Configuración por defecto de memoria Heap para Java 25
ENV HEAP="-Xms1g -Xmx2g -XX:+UseG1GC"

# Directorio de trabajo interno del contenedor
WORKDIR /jmeter

# Punto de entrada por defecto
ENTRYPOINT ["jmeter"]
```

---

## 4. Orquestación con Docker Compose

Crea el archivo `docker-compose.yml` en la raíz del proyecto para simplificar la ejecución del contenedor y la gestión de volúmenes compartidos.

```yaml
version: '3.8'

services:
  jmeter:
    build:
      context: .
      dockerfile: Dockerfile
    image: jmeter-alpine-java25:5.6.3
    container_name: jmeter_runner
    environment:
      - HEAP=-Xms1g -Xmx2g -XX:+UseG1GC
    volumes:
      - .:/jmeter
    # Ejecución en modo CLI (Non-GUI)
    command: >
      -n
      -t /jmeter/test_plan.jmx
      -l /jmeter/results/results.jtl
      -e -o /jmeter/results/html_report
```

---

## 5. Plan de Pruebas de Ejemplo (`test_plan.jmx`)

Si no dispones de un script `.jmx` listo, crea un archivo llamado `test_plan.jmx` en la raíz del proyecto con el siguiente código XML básico de prueba de HTTP:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<jmeterTestPlan version="1.2" properties="5.0" jmeter="5.6.3">
  <hashTree>
    <TestPlan guiclass="TestPlanGui" testclass="TestPlan" testname="Test Plan Java25" enabled="true">
      <elementProp name="TestPlan.user_defined_variables" elementType="Arguments">
        <collectionProp name="Arguments.arguments"/>
      </elementProp>
    </TestPlan>
    <hashTree>
      <ThreadGroup guiclass="ThreadGroupGui" testclass="ThreadGroup" testname="Thread Group Demo" enabled="true">
        <intProp name="ThreadGroup.num_threads">5</intProp>
        <intProp name="ThreadGroup.ramp_time">2</intProp>
        <boolProp name="ThreadGroup.same_user_on_next_iteration">true</boolProp>
        <stringProp name="ThreadGroup.on_sample_error">continue</stringProp>
        <elementProp name="ThreadGroup.main_controller" elementType="LoopController">
          <stringProp name="LoopController.loops">2</stringProp>
        </elementProp>
      </ThreadGroup>
      <hashTree>
        <HTTPSamplerProxy guiclass="HttpTestSampleGui" testclass="HTTPSamplerProxy" testname="HTTP Request - HTTPBin" enabled="true">
          <stringProp name="HTTPSampler.domain">httpbin.org</stringProp>
          <stringProp name="HTTPSampler.protocol">https</stringProp>
          <stringProp name="HTTPSampler.path">/get</stringProp>
          <stringProp name="HTTPSampler.method">GET</stringProp>
        </HTTPSamplerProxy>
        <hashTree/>
      </hashTree>
    </hashTree>
  </hashTree>
</jmeterTestPlan>
```

---

## 6. Paso a Paso para Construir y Ejecutar

### Paso 1: Construir la Imagen Docker
Ejecuta el siguiente comando para generar la imagen localmente:

```bash
docker compose build
```

*Para verificar que la versión de Java interna sea efectivamente la 25, puedes ejecutar:*
```bash
docker run --rm --entrypoint java jmeter-alpine-java25:5.6.3 --version
```

### Paso 2: Ejecutar la Prueba de Carga
Inicia el proceso en modo no interactivo (CLI):

```bash
docker compose up
```

### Paso 3: Monitoreo de Logs
Durante la ejecución verás en la consola métricas periódicas del avance de las peticiones:

```text
jmeter_runner  | summary +      5 in 00:00:02 =    2.5/s Avg:   312 Min:   210 Max:   450 Err:     0 (0.00%)
jmeter_runner  | summary +      5 in 00:00:01 =    4.8/s Avg:   198 Min:   180 Max:   230 Err:     0 (0.00%)
jmeter_runner  | summary =     10 in 00:00:03 =    3.2/s Avg:   255 Min:   180 Max:   450 Err:     0 (0.00%)
jmeter_runner exited with code 0
```

---

## 7. Análisis e Inspección de Resultados

Una vez finalizada la prueba, se habrán generado automáticamente dos elementos dentro del directorio `./results`:

1. **`results.jtl`**: Archivo plano con las métricas en crudo.
2. **`html_report/`**: Carpeta que contiene la interfaz web de reporte estático.

Para ver el dashboard interactivo de JMeter:

1. Abre tu navegador web.
2. Carga el archivo local ubicado en `jmeter-java25-docker/results/html_report/index.html`.

---

## 8. Consideraciones de Rendimiento y Tuning

1. **Ajuste de Memoria Heap:** Si vas a ejecutar miles de usuarios virtuales, incrementa los valores en el bloque `environment` del `docker-compose.yml`:
   ```yaml
   environment:
     - HEAP=-Xms4g -Xmx8g -XX:+UseG1GC
   ```
2. **Límites de Recurso del Contenedor:** Puedes limitar el consumo máximo de hardware en `docker-compose.yml`:
   ```yaml
   deploy:
     resources:
       limits:
         cpus: '4.0'
         memory: 8G
   ```