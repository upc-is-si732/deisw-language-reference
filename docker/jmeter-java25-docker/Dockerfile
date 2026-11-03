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