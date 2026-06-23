1. Crear un Token de Acceso (Recomendado por Seguridad)

- Inicia sesión en Docker Hub.
- Haz clic en tu foto de perfil en la esquina superior derecha y selecciona "Account Settings" (Configuración de la cuenta).
- En el menú izquierdo, ve a "Personal access tocken".
- Haz clic en "Generate new Token" (Nuevo token de acceso).
- Dale una descripción: "jenkins-token" y asígnale permisos de Read, Write, Delete (o solo Read & Write).
- Haz clic en Generate, copia el token y guárdalo bien (no se volverá a mostrar).

2. Autenticarte desde la Terminal (Docker Login)

Abre la terminal de tu computadora (o desde el entorno donde vayas a compilar) y ejecuta:

docker login -u tu_usuario_docker_hub

3. El Nombre de la Imagen (La Regla del "Tagging")

Opción A: Al construirla desde cero (docker build)

docker build -t tu_usuario_docker/learning-center-platform-small:1.0 .

Opción B: Si ya la tenías construida localmente, puedes renombrarla (docker tag)

docker tag learning-center-platform-small:latest tu_usuario_docker/learning-center-platform-small:latest

4. Ejecutar el Comando de Subida (docker push)

Una vez que la imagen tiene tu nombre de usuario y has iniciado sesión, estás listo para subirla a los servidores de Docker Hub.
Ejecuta el siguiente comando:

docker push pcsijflo/learning-center-platform-small:latest