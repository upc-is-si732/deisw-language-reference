# Usamos la última versión oficial de Jenkins LTS basada en JDK 21
# https://hub.docker.com/r/jenkins/jenkins/tags?name=lts-jdk25
FROM jenkins/jenkins:lts-jdk25

# Cambiamos temporalmente al usuario root para realizar la instalación de herramientas
USER root

# Actualizamos los repositorios e instalamos dependencias iniciales esenciales
RUN apt-get update && \
    apt-get install -y maven git curl wget tar apt-transport-https ca-certificates gnupg lsb-release && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# --- NUEVO: INSTALACIÓN DEL CLIENTE DE DOCKER (CLI) ---
# Agregamos la clave GPG oficial de Docker y configuramos su repositorio estable
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalamos únicamente el cliente de Docker (docker-ce-cli) para interactuar con el host
RUN apt-get update && \
    apt-get install -y docker-ce-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Creamos el directorio estructurado para hospedar las múltiples versiones del JDK
RUN mkdir -p /opt/java

# --- INSTALACIÓN DE JDK 24 (Eclipse Temurin de Adoptium) ---
RUN wget -qO- https://api.adoptium.net/v3/binary/latest/24/ga/linux/x64/jdk/hotspot/normal/eclipse | tar -xz -C /opt/java && \
    mv /opt/java/jdk-24* /opt/java/jdk-24

# --- INSTALACIÓN DE JDK 25 (Eclipse Temurin de Adoptium) ---
RUN wget -qO- https://api.adoptium.net/v3/binary/latest/25/ga/linux/x64/jdk/hotspot/normal/eclipse | tar -xz -C /opt/java && \
    mv /opt/java/jdk-25* /opt/java/jdk-25

# --- INSTALACIÓN DE JDK 26 (Eclipse Temurin de Adoptium - Early Access) ---
RUN wget -qO- https://api.adoptium.net/v3/binary/latest/26/ea/linux/x64/jdk/hotspot/normal/eclipse | tar -xz -C /opt/java && \
    mv /opt/java/jdk-26* /opt/java/jdk-26

# Declaramos variables de entorno globales para mapear las rutas de cada JDK
ENV JAVA_HOME_24=/opt/java/jdk-24
ENV JAVA_HOME_25=/opt/java/jdk-25
ENV JAVA_HOME_26=/opt/java/jdk-26

# Volvemos a cambiar al usuario seguro por defecto de Jenkins
USER jenkins

# Copiamos la lista de plugins optimizada dentro del contenedor con los permisos correctos
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt

# Ejecutamos la CLI oficial de Jenkins para descargar e instalar los plugins y sus dependencias
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt