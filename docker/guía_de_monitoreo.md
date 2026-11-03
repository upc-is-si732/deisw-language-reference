# Guía de Monitoreo de Aplicaciones Spring Boot con Prometheus y Grafana en Docker

Esta guía proporciona un paso a paso para configurar la recolección, métricas y visualización en tiempo real de una aplicación **Spring Boot (Java 26)** haciendo uso de **Actuator**, **Micrometer**, **Prometheus** y **Grafana** sobre una red de **Docker**.

## Tabla de Contenidos

1. [Requisitos Previos](#1-requisitos-previos)
2. [Paso 1: Configurar la Aplicación Spring Boot](#paso-1-configurar-la-aplicación-spring-boot)
   * [1. Dependencias (`pom.xml`)](#1-dependencias-pomxml)
   * [2. Configuración de Propiedades (`application.properties`)](#2-configuración-de-propiedades-applicationproperties)
   * [3. Configuración de Spring Security (Opcional)](#3-configuración-de-spring-security-opcional)
   * [4. Verificación de Métricas Nativas](#4-verificación-de-métricas-nativas)
3. [Paso 2: Archivo de Configuración de Prometheus](#paso-2-archivo-de-configuración-de-prometheus)
4. [Paso 3: Despliegue de Contenedores en Docker](#paso-3-despliegue-de-contenedores-en-docker)
   * [1. Creación de la Red Docker](#1-creación-de-la-red-docker)
   * [2. Desplegar Prometheus](#2-desplegar-prometheus)
   * [3. Verificación de Targets en Prometheus](#3-verificación-de-targets-en-prometheus)
   * [4. Desplegar Grafana](#4-desplegar-grafana)
5. [Paso 4: Configurar la Fuente de Datos en Grafana](#paso-4-configurar-la-fuente-de-datos-en-grafana)
6. [Paso 5: Importar el Dashboard de Monitoreo](#paso-5-importar-el-dashboard-de-monitoreo)

---

## 1. Requisitos Previos

* **Docker** y **Docker Desktop** instalados y ejecutándose.
* Proyecto **Spring Boot** funcional expuesto en el puerto `8091` bajo el nombre de contenedor `app-learning`.
* Red de Docker unificada llamada `upc-net`.

---

## Paso 1: Configurar la Aplicación Spring Boot

### 1. Dependencias (`pom.xml`)

Añade las dependencias necesarias de **Spring Boot Actuator** y **Micrometer Prometheus Registry** dentro del archivo `pom.xml`:

```xml
<dependencies>
    <!-- Monitoreo nativo de Spring Boot Actuator -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
    
    <!-- Exportador de métricas en formato compatible con Prometheus -->
    <dependency>
        <groupId>io.micrometer</groupId>
        <artifactId>micrometer-registry-prometheus</artifactId>
    </dependency>
</dependencies>
```

### 2. Configuración de Propiedades (`application.properties`)

Configura la exposición de los endpoints de Actuator y habilita la recolección de métricas detalladas en el archivo `src/main/resources/application.properties`:

```properties
# Exposición de endpoints de Actuator
management.endpoints.web.exposure.include=health,info,metrics,prometheus
management.endpoint.health.show-details=always

# Habilitar métricas detalladas para solicitudes HTTP
management.metrics.web.server.request.autotime.enabled=true
```

### 3. Configuración de Spring Security (Opcional)

Si tu proyecto implementa **Spring Security**, debes permitir el acceso público a las rutas de `/actuator/**` para evitar errores `401 Unauthorized` o `403 Forbidden` durante la lectura de Prometheus.

Crea o actualiza la clase de configuración de seguridad:

```java
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable()) // Deshabilitar CSRF para APIs REST sin estado
            .authorizeHttpRequests(auth -> auth
                // Permite el acceso público a los endpoints de monitoreo de Actuator
                .requestMatchers("/actuator/**").permitAll()
                
                // Endpoints de autenticación u otros endpoints públicos
                .requestMatchers("/api/v1/auth/**").permitAll()
                
                // Cualquier otra solicitud requiere autenticación
                .anyRequest().authenticated()
            );

        return http.build();
    }
}
```

### 4. Verificación de Métricas Nativas

Genera la imagen Docker de tu aplicación, levanta el contenedor en el puerto `8091` y accede a la siguiente URL en tu navegador:

```text
http://localhost:8091/actuator/prometheus
```

**Resultado esperado:** Deberías visualizar una lista de métricas en formato de texto plano con variables como `jvm_memory_used_bytes`, `http_server_requests_seconds_count`, entre otras.

---

## Paso 2: Archivo de Configuración de Prometheus

Prometheus utiliza un archivo de configuración en formato YAML para definir los intervalos de rastreo (*scraping*) y los objetivos (*targets*).

Crea un archivo llamado `prometheus.yml` en el directorio de trabajo donde gestionas tus contenedores:

```yaml
global:
  scrape_interval: 15s # Intervalo de recolección de métricas

scrape_configs:
  - job_name: 'prometheus'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['app-learning:8091'] # Nombre del contenedor y puerto interno de la aplicación
```

> **Nota para usuarios de macOS:** Si requieres generar este archivo mediante consola bash/zsh, puedes ejecutar:
>
> ```bash
> cat <<EOF > ./prometheus.yml
> global:
>   scrape_interval: 15s
> scrape_configs:
>   - job_name: 'prometheus'
>     metrics_path: '/actuator/prometheus'
>     static_configs:
>       - targets: ['app-learning:8091']
> EOF
> ```

---

## Paso 3: Despliegue de Contenedores en Docker

### 1. Creación de la Red Docker

Asegúrate de que la red compartida exista antes de levantar los contenedores:

```bash
docker network create upc-net || true
```

### 2. Desplegar Prometheus

Ejecuta el contenedor de Prometheus mapeando el archivo `prometheus.yml` creado previamente.

#### En Windows (PowerShell / CMD) o Linux:

```bash
docker run -d \
  --name prometheus-server \
  --network upc-net \
  -p 9090:9090 \
  -v ./prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus:latest
```

#### En macOS:

```bash
docker run -d \
  --name prometheus-server \
  --network upc-net \
  -p 9090:9090 \
  -v ${PWD}/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus:latest
```

### 3. Verificación de Targets en Prometheus

1. Ingresa a la consola web de Prometheus: `http://localhost:9090`.
2. En la barra superior, navega a **Status ➔ Targets**.
3. Revisa el estado del job `prometheus`:
   * **Estado UP (Color verde):** Indica que Prometheus se comunica correctamente con la aplicación Spring Boot.
   * **Estado DOWN (Color rojo):** Significa que hay un problema de conectividad o de configuración en la red `upc-net`.

#### Validación de Métricas en Vivo:

1. Regresa a la pestaña **Graph** en Prometheus.
2. Escribe una consulta de prueba en la barra de búsqueda, por ejemplo:
   ```promql
   http_server_requests_seconds_count
   ```
3. Haz clic en **Execute**. Deberías ver los contadores de peticiones procesadas por Spring Boot.

### 4. Desplegar Grafana

Lanza el contenedor de Grafana conectado a la misma red compartida:

```bash
docker run -d \
  --name grafana-server \
  --network upc-net \
  -p 3000:3000 \
  -v grafana_data:/var/lib/grafana \
  grafana/grafana:latest
```

---

## Paso 4: Configurar la Fuente de Datos en Grafana

1. Abre tu navegador e ingresa a Grafana: `http://localhost:3000`.
2. Inicia sesión con las credenciales por defecto:
   * **Usuario:** `admin`
   * **Contraseña:** `admin` *(El sistema solicitará el cambio de contraseña en el primer ingreso)*.
3. En el menú lateral izquierdo, ve a **Connections** ➔ **Data Sources**.
4. Haz clic en **Add data source** y selecciona **Prometheus**.
5. En el campo **Connection ➔ Prometheus server URL**, ingresa el nombre de host del contenedor dentro de la red Docker:
   ```text
   http://prometheus-server:9090
   ```
6. Desplázate al final de la página y haz clic en **Save & test**.
7. **Resultado esperado:** Mensaje de confirmación en color verde: *"Data source is working"*.

---

## Paso 5: Importar el Dashboard de Monitoreo

Para visualizar las métricas de la JVM, peticiones HTTP y rendimiento general de Spring Boot sin construir paneles manualmente, utilizaremos un dashboard preconfigurado de la comunidad.

1. En la consola de Grafana, haz clic en el icono **"+"** (esquina superior derecha) y selecciona **Import dashboard**.
2. En el campo **Find and import dashboards...**, ingresa el ID del dashboard para Spring Boot / JVM:
   ```text
   10280
   ```
   *(También puedes utilizar el ID `4701` como alternativa completa para Micrometer)*.
3. Haz clic en **Load**.
4. En el menú desplegable de la opción **Prometheus**, selecciona la fuente de datos configurada en el Paso 4.
5. Haz clic en **Import**.

¡La configuración se ha completado! Ahora contarás con un panel de monitoreo dinámico en tiempo real para evaluar el rendimiento de tu aplicación en producción o desarrollo.