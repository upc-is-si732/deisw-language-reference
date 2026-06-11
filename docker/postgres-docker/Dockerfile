# 1. IMAGEN BASE
# Usamos la versión estable más reciente (18) de la imagen oficial, basada en Alpine para ser ligera.
FROM postgres:18-alpine

# 2. DIRECTORIO DE INICIALIZACIÓN
# Copiaremos nuestros scripts SQL en el directorio especial de inicialización de PostgreSQL.
# La imagen oficial de PostgreSQL ejecutará automáticamente cualquier .sql o .sh en este directorio.
COPY ./init-scripts/ /docker-entrypoint-initdb.d/

# 3. PUERTO
# Expone el puerto por defecto de PostgreSQL. (Opcional, es documentación).
EXPOSE 5432