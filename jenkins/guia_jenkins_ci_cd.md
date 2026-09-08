# Guía de Laboratorio: Integración Continua con Jenkins y Maven

## **Información del Laboratorio**
* **Materia / Curso:** Integración Continua y Despliegue Continuo (CI/CD) / DevOps
* **Tema:** Configuración de Servidor Jenkins y Creación de Pipelines Declarativos
* **Prerrequisitos:**
  * Git instalado en la máquina local.
  * Java Development Kit (JDK 17 LTS o JDK 21 LTS) configurado.
  * Apache Maven 3.8+ instalado o configurado a nivel de sistema/tooling.

---

## **1. Introducción**

Jenkins es uno de los servidores de automatización de código abierto más utilizados en la industria. Permite a los equipos de desarrollo implementar prácticas de **Integración Continua (CI)** y **Despliegue Continuo (CD)** mediante la automatización de la compilación, pruebas y despliegue de software.

En este laboratorio aprenderás a:
1. Desplegar e inicializar un servidor Jenkins en un entorno local.
2. Configurar las herramientas globales de construcción (JDK, Git, Maven).
3. Compilar y ejecutar una aplicación web Spring Boot basada en Maven.
4. Escribir un pipeline declarativo (`Jenkinsfile`) profesional e integrarlo a un repositorio de SCM (GitHub).
5. Configurar disparadores automáticos por cambios en el control de versiones (*Poll SCM / Webhooks*).

---

## **2. Instalación e Inicialización de Jenkins**

### **2.0. Instalacion de Java y Maven**

Verificar Versiones instaladas:
```
/usr/libexec/java_home -V
```

**Descargar Java 21:**
```
https://adoptium.net/temurin/releases/?version=21
```

**Instalacion Java 21**

Instale la version de java descargada.

**Configuración de Java:**

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
export PATH=$JAVA_HOME/bin:$PATH
java -version
```

**Descargar Maven (En el caso no lo tenga instalado)**
```
https://maven.apache.org/download.cgi
```

**Configurar Maven**
```
export M2_HOME="/Users/alumnos/Documents/soporte/apache-maven-3.9.11" # Reemplaza con tu ruta de Maven
export PATH="${M2_HOME}/bin:${PATH}"
```

### **2.1. Descarga del paquete WAR**
1. Ingresa a la página oficial de descargas de Jenkins: [https://www.jenkins.io/download/](https://www.jenkins.io/download/).
2. En la sección **Jenkins LTS (Long Term Support)**, selecciona la opción **Generic Java package (.war)**.

> **Nota de Versión Modernizada:** Se recomienda ejecutar Jenkins con **Java 17** o **Java 21**, ya que versiones anteriores como Java 8 y 11 han entrado en fase de deprecación en versiones recientes de Jenkins LTS.

---

### **2.2. Ejecución de Jenkins vía Consola**
1. Crea un directorio local de trabajo, por ejemplo `C:\jenkins` o `~/jenkins`.
2. Mueve el archivo `jenkins.war` descargado a dicho directorio.
3. Abre una terminal de comandos (Bash, PowerShell o Terminal) en la ubicación del archivo.
4. Ejecute el siguiente comando para iniciar el servidor de Jenkins en el puerto de su elección (ej. puerto `9089` u `8080`):

```bash
java -jar jenkins.war --httpPort=9089
```

5. Durante la inicialización en la consola, observe el bloque de salida que contiene la contraseña administrativa temporal:

```text
*************************************************************
*************************************************************
Jenkins initial setup is required. An admin user has been created and a password generated.
Please use the following password to proceed to installation:

b7b22002c2f04b8e9be5fc9a3a76ad99

This may also be found at: C:\Users\<usuario>\.jenkins\secrets\initialAdminPassword
*************************************************************
*************************************************************
```

---

### **2.3. Asistente de Configuración Inicial**

1. Abre un navegador web e ingresa a: **`http://localhost:9089/`**
2. **Unlock Jenkins:** Pega la clave administrativa inicial mostrada en la consola y presiona **Continue**.
3. **Customize Jenkins:** Selecciona la opción **Install suggested plugins** (Instalar plugins sugeridos).
4. Espera a que el proceso de instalación de plugins (Git, Pipeline, Folders, Credentials, etc.) finalice.
5. **Create First Admin User:** Completa los datos para crear el usuario administrador principal:
   * **Username:** `jenkins_admin`
   * **Password:** *(Crea una contraseña segura)*
   * **Full Name:** Administrador DevOps
   * **E-mail:** `admin@midominio.com`
6. **Instance Configuration:** Confirma la URL de la instancia (ej. `http://localhost:9089/`) y haz clic en **Save and Finish**.
7. Haz clic en **Start using Jenkins**.

---

## **3. Configuración de Herramientas Globales (*Global Tool Configuration*)**

Para que Jenkins pueda compilar el código fuente Java/Maven y clonar repositorios de Git, debemos indicarle la ubicación de dichas herramientas o configurar su descarga automática.

1. En el panel lateral izquierdo, ve a **Manage Jenkins** $\rightarrow$ **Tools** (o *Global Tool Configuration* según la versión).

### **3.1. Configuración del JDK**
1. Dirígete a la sección **JDK** y haz clic en **Add JDK**.
2. **Name:** `JDK_17` (o `JDK_21`).
3. Desmarca *Install automatically* si deseas usar una instalación local existente.
4. **JAVA_HOME:** Ingresa la ruta absoluta de instalación de tu JDK.
   * *Ejemplo Windows:* `C:\Program Files\Java\jdk-17`
   * *Ejemplo Linux/Mac:* `/usr/lib/jvm/java-17-openjdk`

---

### **3.2. Configuración de Git**
1. Dirígete a la sección **Git** $\rightarrow$ **Git installations**.
2. **Name:** `Default`
3. **Path to Git executable:**
   * *Ejemplo Windows:* `C:\Program Files\Git\cmd\git.exe`
   * *Ejemplo Linux/Mac:* `/usr/bin/git`

---

### **3.3. Configuración de Apache Maven**
1. Dirígete a la sección **Maven** $\rightarrow$ **Maven installations**.
2. Haz clic en **Add Maven**.
3. **Name:** `MAVEN_3_9`
4. Marca la casilla **Install automatically**.
5. Selecciona en la lista desplegable la versión más reciente (ej. `3.9.x` o superior).
6. Haz clic en **Save** (Guardar) al final de la página.

---

## **4. Instalación de Plugins Adicionales**

Para integrar pipelines declarativos de manera óptima con Maven, aseguraremos la presencia del plugin **Pipeline Maven Integration**.

1. Ve a **Manage Jenkins** $\rightarrow$ **Plugins**.
2. Selecciona la pestaña **Available plugins** (Plugins disponibles).
3. En la barra de búsqueda, escribe: `Pipeline Maven Integration`.
4. Selecciona la casilla correspondiente y haz clic en **Install without restart**.
5. Una vez terminada la instalación, selecciona **Go back to the top page**.

---

## **5. Descarga, Compilación y Ejecución Manual de la Aplicación**

Antes de automatizar el proceso en Jenkins, probaremos la construcción manual de la aplicación objetivo en el entorno local.

### **5.1. Clonar el Repositorio**
Abre una terminal y ejecuta el comando de clonación:

```bash
git clone https://github.com/upc-is-si732/learning-center-platform-small-v2520.git
cd learning-center-platform-small-v2520
```

---

### **5.2. Compilación e Instalación Local**
Ejecuta el ciclo de construcción de Maven para validar el código y empaquetar el entregable (`.war` / `.jar`):

```bash
mvn clean install
```

Si la compilación es exitosa, verás el mensaje **BUILD SUCCESS** y el artefacto compilado dentro de la carpeta `target/`.

---

### **5.3. Ejecución de la Aplicación Spring Boot**
Para desplegar la aplicación empaquetada:

```bash
cd target
java -jar learning-center-platform-small-0.0.1-SNAPSHOT.jar
```

Accede a tu navegador en la siguiente ruta para verificar el funcionamiento:
**`http://localhost:8091/swagger-ui/index.html`**

---

## **6. Creación del Pipeline Declarativo (`Jenkinsfile`)**

Un **Pipeline Declarativo** es un archivo de texto (`Jenkinsfile`) que define el flujo de Integración y Despliegue Continua como código (*Pipeline as Code*).

### **6.1. Definición del `Jenkinsfile`**
Crea o edita el archivo llamado `Jenkinsfile` (sin extensión) en la raíz del proyecto Git con el siguiente contenido modernizado y sintácticamente correcto:

```groovy
pipeline {
  agent any
  tools {
    maven 'MAVEN_3_9_11'
    jdk 'JDK_24'
  }
	environment {
		REGISTRY_USER = "pcsijflo" // Cambia por tu usuario real de Docker Hub
        // Nombre de la imagen que vamos a crear para nuestra aplicación
        IMAGE_NAME = "learning-center-platform-small"
        TAG        = "${env.BUILD_NUMBER}" // Usa el número de ejecución de Jenkins como versión
    }

  stages {
    stage ('Compile Project') {
      steps {
        withMaven(maven : 'MAVEN_3_9_11') {
            sh 'mvn clean compile'
        }
      }
    }

    stage('Validate Checkstyle') {
      steps {
        withMaven(maven: 'MAVEN_3_9_11') {
          sh 'mvn checkstyle:check'
        }
      }
    }

    stage('Validate Unit Tests') {
      steps {
        withMaven(maven: 'MAVEN_3_9_11') {
          sh 'mvn test'
        }
      }
    }

    stage('Validate Test Coverage') {
      steps {
        withMaven(maven: 'MAVEN_3_9_11') {
          sh 'mvn clean verify jacoco:report'
          sh 'mvn jacoco:check'
        }
      }
    }

}
```

---

## **7. Configuración del Job en Jenkins**

1. Regresa al **Dashboard** de Jenkins y haz clic en **New Item** (Nuevo Elemento).
2. Ingresa el nombre del proyecto: `Pipeline_Sistema_Ventas`.
3. Selecciona el tipo de proyecto **Pipeline** y haz clic en **OK**.
4. En la pestaña **General**, añade una descripción breve.
5. Ve a la sección **Pipeline**:
   * **Definition:** Selecciona `Pipeline script from SCM`.
   * **SCM:** Selecciona `Git`.
   * **Repository URL:** `https://github.com/upc-is-si732/learning-center-platform-small-v2520.git`
   * **Branch Specifier:** `*/master` o `*/main`
   * **Script Path:** `Jenkinsfile`
6. Haz clic en **Save** (Guardar).

---

## **8. Automatización de Integración Continua (Disparadores / Triggers)**

Para lograr una verdadera Integración Continua, el pipeline debe ser capaz de reaccionar automáticamente cuando un desarrollador suba cambios al repositorio.

### **8.1. Opción A: Consultar el Repositorio (Poll SCM)**
Jenkins revisará periódicamente si existen nuevos commits en GitHub.

1. En la configuración del Job `Pipeline_Sistema_Ventas`, ve a la sección **Build Triggers**.
2. Marca la casilla **Poll SCM** (Consultar repositorio SCM).
3. En el campo **Schedule**, ingresa la expresión Cron. Por ejemplo, para consultar cada 2 minutos:

```cron
H/2 * * * *
```

4. Haz clic en **Save**.

---

### **8.2. Opción B: GitHub Webhook (Mejor Práctica DevOps)**
En entornos de producción, se prefiere el uso de **Webhooks** sobre el polling para evitar sobrecarga en los servidores.

1. En la sección **Build Triggers**, marca **GitHub hook trigger for GITScm polling**.
2. En tu repositorio de GitHub, ve a **Settings** $\rightarrow$ **Webhooks** $\rightarrow$ **Add webhook**.
3. **Payload URL:** `http://<TU_IP_O_DOMINIO>:9089/github-webhook/`
4. **Content type:** `application/json`
5. Guarda el webhook. Cada evento `push` desencadenará una construcción automática de forma instantánea.

---

## **9. Ejecución y Validación del Pipeline**

1. En el menú del Job, haz clic en **Build Now** (Construir ahora) para ejecutar el flujo manualmente por primera vez.
2. Observa la sección **Stage View** para visualizar el avance paso a paso:
   * **Checkout SCM** $\rightarrow$ **Compile Stage** $\rightarrow$ **Testing Stage** $\rightarrow$ **Package Stage**.
3. Haz clic en la ejecución correspondiente (`#1`, `#2`, etc.) y luego en **Console Output** para auditar los registros detallados de salida de Maven y Java.

---

## **10. Resumen de Buenas Prácticas Aplicadas**

| Práctica DevOps | Beneficio / Explicación |
| :--- | :--- |
| **Pipeline as Code (`Jenkinsfile`)** | Permite versionar la infraestructura y flujos de integración junto con el código fuente. |
| **Aislamiento de Etapas (*Stages*)** | Facilita la identificación precisa de fallos (ej. saber si falló en compilación o en pruebas). |
| **Uso de Bloques `post`** | Garantiza la recolección de reportes de pruebas unitarias (`JUnit`) aunque el flujo falle. |
| **Uso de Webhooks vs Polling** | Reduce llamadas innecesarias al servidor de SCM, optimizando recursos de red y CPU. |
| **Inmutabilidad y Limpieza** | Los comandos `mvn clean` aseguran builds limpios desde cero evitando artefactos obsoletos. |
