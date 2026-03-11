# Proyecto Base HAPI-FHIR

> **ℹ️ Nota Importante**: Este proyecto usa **Maven Wrapper 3.3.2** (incluido en el repositorio). **NO necesitas instalar Maven** globalmente. Los archivos `mvnw.cmd` y `.mvn/wrapper/maven-wrapper.jar` ya están incluidos. Todos los comandos usan `.\mvnw.cmd` en lugar de `mvn`.

Este proyecto es un proyecto inicial completo que puedes usar para desplegar un servidor FHIR usando HAPI FHIR JPA.

Ten en cuenta que este proyecto está específicamente diseñado para usuarios finales del módulo servidor HAPI FHIR JPA (en otras palabras, te ayuda a implementar HAPI FHIR, no es la fuente de la librería en sí). Si estás buscando el proyecto principal de HAPI FHIR, mira aquí: https://github.com/hapifhir/hapi-fhir

Si bien este proyecto muestra cómo puedes usar muchas partes del framework HAPI FHIR, hay un conjunto de características que debes tener en cuenta que faltan o que necesitas proporcionar tú mismo o obtener soporte profesional antes de usarlo directamente en producción:

1) El servicio no incluye implementación de seguridad. Ve cómo se puede hacer [aquí](https://hapifhir.io/hapi-fhir/docs/security/introduction.html)
2) El servicio no incluye registro empresarial. Ve cómo se puede hacer [aquí](https://hapifhir.io/hapi-fhir/docs/security/balp_interceptor.html)
3) El caché interno de tópicos usado por las suscripciones en HAPI FHIR no se comparte entre múltiples instancias ya que la [implementación predeterminada está en memoria](https://github.com/hapifhir/hapi-fhir/blob/master/hapi-fhir-jpaserver-subscription/src/main/java/ca/uhn/fhir/jpa/topic/ActiveSubscriptionTopicCache.java)
4) El canal interno del broker de mensajes en HAPI FHIR no se comparte entre múltiples instancias ya que la [implementación predeterminada está en memoria](https://github.com/hapifhir/hapi-fhir/blob/master/hapi-fhir-storage/src/main/java/ca/uhn/fhir/jpa/subscription/channel/api/IChannelFactory.java). Esto impacta el uso de módulos listados [aquí](https://smilecdr.com/docs/installation/message_broker.html#modules-dependent-on-message-brokers)

¿Necesitas Ayuda? Por favor consulta: https://github.com/hapifhir/hapi-fhir/wiki/Getting-Help

## Prerequisitos

Para usar este ejemplo, debes tener:

- [Este proyecto](https://github.com/hapifhir/hapi-fhir-jpaserver-starter) clonado. Puedes crear un Fork en GitHub del proyecto y clonarlo en su lugar para que puedas personalizar el proyecto y guardar los resultados en GitHub.

### y cualquiera de estos
 - Oracle Java (JDK) instalado: Mínimo JDK17 o superior.
 - **Maven Wrapper 3.3.2** (incluido en el proyecto, NO necesita instalación global de Maven)

### o
 - Docker, ya que todo el proyecto puede ser construido usando docker multietapa (con JDK y maven envueltos en docker) o usado directamente desde [Docker Hub](https://hub.docker.com/r/hapiproject/hapi)

## Ejecutar vía [Docker Hub](https://hub.docker.com/r/hapiproject/hapi)

Cada versión etiquetada/liberada de `hapi-fhir-jpaserver` se construye como una imagen de Docker y se publica en Docker Hub. Para ejecutar la imagen Docker publicada desde DockerHub:

```
docker pull hapiproject/hapi:latest
docker run -p 8080:8080 hapiproject/hapi:latest
```

Esto ejecutará la imagen docker con la configuración predeterminada, mapeando el puerto 8080 del contenedor al puerto 8080 en el host. Una vez en ejecución, puedes acceder a `http://localhost:8080/` en el navegador para acceder a la interfaz del servidor HAPI FHIR o usar `http://localhost:8080/fhir/` como la URL base para tus peticiones REST.

Si cambias el puerto mapeado, necesitas cambiar la configuración usada por HAPI para tener la propiedad/valor correcto de `hapi.fhir.tester`.

### Configuración mediante variables de entorno

Puedes personalizar HAPI directamente desde el comando `run` usando variables de entorno. Por ejemplo:

```
docker run -p 8080:8080 -e hapi.fhir.default_encoding=xml hapiproject/hapi:latest
```

HAPI busca en las variables de entorno las propiedades del archivo [application.yaml](https://github.com/hapifhir/hapi-fhir-jpaserver-starter/blob/master/src/main/resources/application.yaml) para los valores predeterminados.

### Configuración de almacenamiento binario

Para transmitir cargas útiles `Binary` grandes al disco en lugar de a la base de datos, configura el proyecto con propiedades de almacenamiento en sistema de archivos:

```
hapi:
  fhir:
    binary_storage_enabled: true
    binary_storage_mode: FILESYSTEM
    binary_storage_filesystem_base_directory: /binstore
    # inline_resource_storage_below_size: 131072   # anulación opcional
```

Cuando `binary_storage_mode` está configurado como `FILESYSTEM` y se omite `inline_resource_storage_below_size`, el proyecto aplica automáticamente un umbral de 102400 bytes (100 KB) en línea para que las cargas más pequeñas permanezcan en la base de datos. Asegúrate de que el directorio al que apuntes sea escribible por el proceso (para construcciones Docker, móntalo en el contenedor con los permisos apropiados).

### Configuración mediante archivo application.yaml personalizado y usando Docker

Puedes personalizar HAPI indicándole que busque el archivo de configuración en una ubicación diferente, por ejemplo:

```
docker run -p 8090:8080 -v $(pwd)/yourLocalFolder:/configs -e "--spring.config.location=file:///configs/another.application.yaml" hapiproject/hapi:latest
```
Aquí, el archivo de configuración (*another.application.yaml*) se coloca localmente en la carpeta *yourLocalFolder*.



```
docker run -p 8090:8080 -e "--spring.config.location=classpath:/another.application.yaml" hapiproject/hapi:latest
```
Aquí, el archivo de configuración (*another.application.yaml*) es parte del conjunto compilado de recursos.

### Línea única para instalar rápidamente una Guía de Implementación en HAPI

```
docker run -p 8080:8080 -e "hapi.fhir.implementationguides.someIg.name=com.org.something" -e "hapi.fhir.implementationguides.someIg.version=1.2.3" -e "hapi.fhir.implementationguides.someIg.packageUrl=https://build.fhir.org/ig/yourOrg/yourIg/package.tgz" -e "hapi.fhir.implementationguides.someIg.installMode=STORE_AND_INSTALL" hapiproject/hapi:latest
```

### Ejemplo usando ``docker-compose.yml`` para docker-compose

```yaml
version: '3.7'

services:
  fhir:
    container_name: fhir
    image: "hapiproject/hapi:latest"
    ports:
      - "8080:8080"
    configs:
      - source: hapi
        target: /app/config/application.yaml
    depends_on:
      - db


  db:
    image: postgres
    restart: always
    environment:
      POSTGRES_PASSWORD: admin
      POSTGRES_USER: admin
      POSTGRES_DB: hapi
    volumes:
      - ./hapi.postgress.data:/var/lib/postgresql/data

configs:
  hapi:
     file: ./hapi.application.yaml
```

Proporciona el siguiente contenido en ``./hapi.application.yaml``:

```yaml
spring:
  datasource:
    url: 'jdbc:postgresql://db:5432/hapi'
    username: admin
    password: admin
    driverClassName: org.postgresql.Driver
  jpa:
    properties:
      hibernate.dialect: ca.uhn.fhir.jpa.model.dialect.HapiFhirPostgresDialect
      hibernate.search.enabled: false
```

### Ejemplo ejecutando interceptor personalizado usando docker-compose

Este ejemplo es una extensión del anterior, ahora agregando un interceptor personalizado.

```yaml
version: '3.7'

services:
  fhir:
    container_name: fhir
    image: "hapiproject/hapi:latest"
    ports:
      - "8080:8080"
    configs:
      - source: hapi
        target: /app/config/application.yaml
      - source: hapi-extra-classes
        target: /app/extra-classes
    depends_on:
      - db

  db:
    image: postgres
    restart: always
    environment:
      POSTGRES_PASSWORD: admin
      POSTGRES_USER: admin
      POSTGRES_DB: hapi
    volumes:
      - ./hapi.postgress.data:/var/lib/postgresql/data

configs:
  hapi:
     file: ./hapi.application.yaml
  hapi-extra-classes:
     file: ./hapi-extra-classes
```

Proporciona el siguiente contenido en ``./hapi.application.yaml``:

```yaml
spring:
  datasource:
    url: 'jdbc:postgresql://db:5432/hapi'
    username: admin
    password: admin
    driverClassName: org.postgresql.Driver
  jpa:
    properties:
      hibernate.dialect: ca.uhn.fhir.jpa.model.dialect.HapiFhirPostgresDialect
      hibernate.search.enabled: false
hapi:
  fhir:
    custom-bean-packages: the.package.containing.your.interceptor
    custom-interceptor-classes: the.package.containing.your.interceptor.YourInterceptor
```

La estructura básica del interceptor sería así:

```java
package the.package.containing.your.interceptor;

import org.hl7.fhir.instance.model.api.IBaseResource;
import org.springframework.stereotype.Component;

import ca.uhn.fhir.interceptor.api.Hook;
import ca.uhn.fhir.interceptor.api.Interceptor;
import ca.uhn.fhir.interceptor.api.Pointcut;

@Component
@Interceptor
public class YourInterceptor
{
    @Hook(Pointcut.STORAGE_PRECOMMIT_RESOURCE_CREATED)
    public void resourceCreated(IBaseResource newResource)
    {
        System.out.println("YourInterceptor.resourceCreated");
    }
}
```

## Ejecución local

La forma más fácil de ejecutar este servidor depende completamente de los requisitos de tu entorno. Se admiten las siguientes formas:

### Usando jetty
```bash
.\mvnw.cmd -Pjetty spring-boot:run
```

Después, el servidor será accesible en http://localhost:8080/fhir y el CapabilityStatement se encontrará en http://localhost:8080/fhir/metadata.

### Usando Spring Boot
```bash
.\mvnw.cmd spring-boot:run
```

Después, el servidor será accesible en http://localhost:8080/fhir y el CapabilityStatement se encontrará en http://localhost:8080/fhir/metadata.

Si quieres ejecutar este servidor en un puerto diferente, puedes cambiar el puerto en el archivo `src/main/resources/application.yaml` de la siguiente manera:

```yaml
server:
#  servlet:
#    context-path: /example/path
  port: 8888
```

El servidor entonces será accesible en http://localhost:8888/fhir y el CapabilityStatement se encontrará en http://localhost:8888/fhir/metadata. Recuerda ajustar tu configuración de superposición en el archivo `application.yaml` de la siguiente manera:

```yaml
    tester:
      -
          id: home
          name: Local Tester
          server_address: 'http://localhost:8888/fhir'
          refuse_to_fetch_third_party_urls: false
          fhir_version: R4
```

### Usando Spring Boot con :run
```bash
.\mvnw.cmd clean spring-boot:run -Pboot
```
Después, el servidor será accesible en http://localhost:8080/ y por ejemplo http://localhost:8080/fhir/metadata. Recuerda ajustar tu configuración de superposición en el application.yaml de la siguiente manera:

```yaml
    tester:
      -
          id: home
          name: Local Tester
          server_address: 'http://localhost:8080/fhir'
          refuse_to_fetch_third_party_urls: false
          fhir_version: R4
```

### Usando Spring Boot
```bash
.\mvnw.cmd clean package spring-boot:repackage -DskipTests=true -Pboot && java -jar target/ROOT.war
```
Después, el servidor será accesible en http://localhost:8080/ y por ejemplo http://localhost:8080/fhir/metadata. Recuerda ajustar tu configuración de superposición en el application.yaml de la siguiente manera:

```yaml
    tester:
      -
          id: home
          name: Local Tester
          server_address: 'http://localhost:8080/fhir'
          refuse_to_fetch_third_party_urls: false
          fhir_version: R4
```
### Usando Spring Boot y Google distroless
```bash
.\mvnw.cmd clean package com.google.cloud.tools:jib-maven-plugin:dockerBuild -Dimage=distroless-hapi && docker run -p 8080:8080 distroless-hapi
```
Después, el servidor será accesible en http://localhost:8080/ y por ejemplo http://localhost:8080/fhir/metadata. Recuerda ajustar tu configuración de superposición en el application.yaml de la siguiente manera:

```yaml
    tester:
      -
          id: home
          name: Local Tester
          server_address: 'http://localhost:8080/fhir'
          refuse_to_fetch_third_party_urls: false
          fhir_version: R4
```

### Usando el Dockerfile y construcción multietapa
```bash
./build-docker-image.sh && docker run -p 8080:8080 hapi-fhir/hapi-fhir-jpaserver-starter:latest
```
Después, el servidor será accesible en http://localhost:8080/ y por ejemplo http://localhost:8080/fhir/metadata. Recuerda ajustar tu configuración de superposición en el application.yaml de la siguiente manera:

```yaml
    tester:
      -
          id: home
          name: Local Tester
          server_address: 'http://localhost:8080/fhir'
          refuse_to_fetch_third_party_urls: false
          fhir_version: R4
```

## Configuraciones

Gran parte de este proyecto inicial de HAPI puede configurarse usando el archivo yaml en _src/main/resources/application.yaml_. Por defecto, este proyecto inicial está configurado para usar H2 como base de datos.

### Configuración de MySQL

HAPI FHIR JPA Server no admite MySQL ya que está obsoleto.

Ve más en https://hapifhir.io/hapi-fhir/docs/server_jpa/database_support.html

### Configuración de PostgreSQL

Para configurar la aplicación inicial para usar PostgreSQL, en lugar del H2 predeterminado, actualiza el archivo application.yaml para tener lo siguiente:

```yaml
spring:
  datasource:
    url: 'jdbc:postgresql://localhost:5432/hapi'
    username: admin
    password: admin
    driverClassName: org.postgresql.Driver
  jpa:
    properties:
      hibernate.dialect: ca.uhn.fhir.jpa.model.dialect.HapiFhirPostgresDialect
      hibernate.search.enabled: false

      # Luego comenta todo hibernate.search.backend.*
```

Debido a que las pruebas de integración dentro del proyecto dependen de la configuración predeterminada de la base de datos H2, es importante omitir explícitamente las pruebas de integración durante el proceso de construcción, es decir, `.\mvnw.cmd install -DskipTests`, o eliminar las pruebas por completo. No omitir o eliminar las pruebas una vez que hayas configurado PostgreSQL para datasource.driver, datasource.url y hibernate.dialect como se detalla arriba resultará en errores de construcción y fallo de compilación.

### Configuración de Microsoft SQL Server

Para configurar la aplicación inicial para usar MS SQL Server, en lugar del H2 predeterminado, actualiza el archivo application.yaml para tener lo siguiente:

```yaml
spring:
  datasource:
    url: 'jdbc:sqlserver://<server>:<port>;databaseName=<databasename>'
    username: admin
    password: admin
    driverClassName: com.microsoft.sqlserver.jdbc.SQLServerDriver
```

Además, asegúrate de no estar configurando el dialecto de Hibernate explícitamente, en otras palabras, elimina cualquier línea similar a:

```
hibernate.dialect: {algún dialecto que no sea Microsoft SQL}
```


Debido a que las pruebas de integración dentro del proyecto dependen de la configuración predeterminada de la base de datos H2, es importante omitir explícitamente las pruebas de integración durante el proceso de construcción, es decir, `.\mvnw.cmd install -DskipTests`, o eliminar las pruebas por completo. No omitir o eliminar las pruebas una vez que hayas configurado PostgreSQL para datasource.driver, datasource.url y hibernate.dialect como se detalla arriba resultará en errores de construcción y fallo de compilación.


NOTA: MS SQL Server por defecto usa una página de códigos insensible a mayúsculas/minúsculas. Esto causará errores con algunas operaciones - como al expandir conjuntos de valores sensibles a mayúsculas/minúsculas (UCUM) ya que hay índices únicos definidos en las tablas de terminología para códigos.
Se recomienda desplegar una base de datos sensible a mayúsculas/minúsculas antes de ejecutar HAPI FHIR cuando uses MS SQL Server para evitar estos y potencialmente otros problemas.

## Agregar interceptores personalizados
Los interceptores personalizados pueden registrarse con el servidor incluyendo la propiedad `hapi.fhir.custom-interceptor-classes`. Esto tomará una lista separada por comas de nombres de clases completamente calificados que se registrarán con el servidor.
Los interceptores se descubrirán de una de dos formas:

1) Desde el contexto de la aplicación Spring como Beans existentes (puede usarse junto con `hapi.fhir.custom-bean-packages`) o registrados con Spring mediante otros métodos
2) Las clases se instanciarán mediante reflexión si no se encuentra ningún Bean coincidente

Los interceptores también pueden registrarse manualmente a través de `RestfulServer.registerInterceptor`. Ten en cuenta que cualquier interceptor registrado de esta manera _no se ejecutará_ para operaciones no REST, por ejemplo, creación a través de un DAO. Para activarse en este caso, necesitas registrar tus interceptores en el bean `IInterceptorService`.

## Agregar operaciones personalizadas (proveedores)
Las operaciones personalizadas (proveedores) pueden registrarse con el servidor incluyendo la propiedad `hapi.fhir.custom-provider-classes`. Esto tomará una lista separada por comas de nombres de clases completamente calificados que se registrarán con el servidor.
Los proveedores se descubrirán de una de dos formas:

1) descubiertos desde el contexto de la aplicación Spring como Beans existentes (puede usarse junto con `hapi.fhir.custom-bean-packages`) o registrados con Spring mediante otros métodos

o

2) las clases se instanciarán mediante reflexión si no se encuentra ningún Bean coincidente

## Personalizar la interfaz de usuario de la página web de pruebas

La interfaz que viene con este servidor es un clon exacto del servidor disponible en [http://hapi.fhir.org](http://hapi.fhir.org). Puedes personalizar esta interfaz si lo deseas. Por ejemplo, podrías cambiar el texto introductorio o reemplazar el logo con el tuyo propio.

La interfaz se personaliza usando archivos de plantilla de [Thymeleaf](https://www.thymeleaf.org/). Quizás quieras aprender más sobre Thymeleaf, pero no necesariamente lo necesitas: son bastante fáciles de entender.

Varios archivos de plantilla que pueden personalizarse se encuentran en el siguiente directorio: [https://github.com/hapifhir/hapi-fhir-jpaserver-starter/tree/master/src/main/webapp/WEB-INF/templates](https://github.com/hapifhir/hapi-fhir-jpaserver-starter/tree/master/src/main/webapp/WEB-INF/templates)

## Desplegar en un Servidor de Aplicaciones

Usar el método Maven Wrapper-Embedded Jetty anterior es conveniente, pero no es una buena solución si quieres dejar el servidor ejecutándose en segundo plano.

La mayoría de las personas que están usando HAPI FHIR JPA como un servidor accesible a otras personas (ya sea internamente en tu red o alojado públicamente) lo harán usando un Servidor de Aplicaciones, como [Apache Tomcat](http://tomcat.apache.org/) o [Jetty](https://www.eclipse.org/jetty/). Ten en cuenta que cualquier Contenedor Web compatible con Servlet 3.0+ funcionará (por ejemplo, Wildfly, Websphere, etc.).

Tomcat es muy popular, por lo que es una buena elección simplemente porque podrás encontrar muchos tutoriales en línea. Jetty es una gran alternativa debido a su rápido tiempo de arranque y buen rendimiento general.

Para desplegar en un contenedor, primero debes construir el proyecto:

```bash
mvn clean install
```

Esto creará un archivo llamado `ROOT.war` en tu directorio `target`. Este debe instalarse en tu Contenedor Web según las instrucciones para tu contenedor particular. Por ejemplo, si estás usando Tomcat, querrás copiar este archivo al directorio `webapps/`.

Nuevamente, navega al siguiente enlace para usar el servidor (ten en cuenta que el puerto 8080 puede no ser correcto dependiendo de cómo esté configurado tu servidor).

[http://localhost:8080/](http://localhost:8080/)

Luego podrás acceder al servidor JPA, por ejemplo, usando http://localhost:8080/fhir/metadata.

Si te gustaría que se aloje en, por ejemplo, hapi-fhir-jpaserver, es decir, http://localhost:8080/hapi-fhir-jpaserver/ o http://localhost:8080/hapi-fhir-jpaserver/fhir/metadata - entonces renombra el archivo WAR a ```hapi-fhir-jpaserver.war``` y ajusta la configuración de superposición en consecuencia, por ejemplo:

```yaml
    tester:
      -
          id: home
          name: Local Tester
          server_address: 'http://localhost:8080/hapi-fhir-jpaserver/fhir'
          refuse_to_fetch_third_party_urls: false
          fhir_version: R4
```


## Desplegar con docker compose

Docker compose es una opción simple para construir y desplegar contenedores. Para desplegar con docker compose, debes construir el proyecto
con `.\mvnw.cmd clean install` y luego levantar los contenedores con `docker-compose up -d --build`. El servidor puede ser
alcanzado en http://localhost:8080/.

Para usar otro puerto, cambia el parámetro `ports`
dentro de `docker-compose.yml` a `8888:8080`, donde 8888 es un puerto de tu elección.

El conjunto de docker compose también incluye base de datos PostgreSQL, si eliges usar PostgreSQL en lugar de H2, cambia las siguientes
propiedades en `src/main/resources/application.yaml`:

```yaml
spring:
  datasource:
    url: 'jdbc:postgresql://hapi-fhir-postgres:5432/hapi'
    username: admin
    password: admin
    driverClassName: org.postgresql.Driver
jpa:
  properties:
    hibernate.dialect: ca.uhn.fhir.jpa.model.dialect.HapiFhirPostgresDialect
    hibernate.search.enabled: false

    # Then comment all hibernate.search.backend.*
```

## Ejecutar hapi-fhir-jpaserver directamente desde IntelliJ como Spring Boot
Asegúrate de ejecutar con el perfil de Maven Wrapper llamado ```boot``` y NO también ```jetty```. Entonces estarás listo para depurar el proyecto directamente sin Servidores de Aplicaciones adicionales.

## Ejecutar hapi-fhir-jpaserver-example en Tomcat desde IntelliJ

Instala Tomcat.

Asegúrate de tener Tomcat configurado en IntelliJ.

- File->Settings->Build, Execution, Deployment->Application Servers
- Haz clic en +
- Selecciona "Tomcat Server"
- Ingresa la ruta a tu despliegue de tomcat tanto para Tomcat Home (IntelliJ rellenará el directorio base por ti)

Agrega una Configuración de Ejecución para ejecutar hapi-fhir-jpaserver-example bajo Tomcat

- Run->Edit Configurations
- Haz clic en el + verde
- Selecciona Tomcat Server, Local
- Cambia el nombre a lo que desees
- Desmarca la casilla "After launch"
- En la pestaña "Deployment", haz clic en el + verde
- Selecciona "Artifact"
- Selecciona "hapi-fhir-jpaserver-example:war"
- En "Application context" escribe /hapi

Ejecuta la configuración.

- Ahora deberías tener "Application Servers" en la lista de ventanas en la parte inferior.
- Haz clic en ella.
- Selecciona tu servidor, y haz clic en el triángulo verde (o el insecto si quieres depurar)
- Espera a que la salida de la consola se detenga

Apunta tu navegador (o fiddler, o lo que sea) a `http://localhost:8080/hapi/baseDstu3/Patient`

## Habilitar Suscripciones

El servidor puede configurarse con soporte de suscripciones habilitando propiedades en el archivo [application.yaml](https://github.com/hapifhir/hapi-fhir-jpaserver-starter/blob/master/src/main/resources/application.yaml):

- `hapi.fhir.subscription.resthook_enabled` - Habilita suscripciones REST Hook, donde el servidor hará una conexión saliente a un servidor REST remoto

- `hapi.fhir.subscription.email.*` - Habilita suscripciones de correo electrónico. Ten en cuenta que también debes proporcionar los detalles de conexión para un servidor SMTP utilizable.

- `hapi.fhir.subscription.websocket_enabled` - Habilita suscripciones websocket. Con esto habilitado, tu servidor aceptará conexiones websocket entrantes en la siguiente URL (este ejemplo usa la ruta de contexto y puerto predeterminados, es posible que necesites ajustar dependiendo de tu entorno de despliegue): [ws://localhost:8080/websocket](ws://localhost:8080/websocket)

## Habilitar Razonamiento Clínico

Establece `hapi.fhir.cr.enabled=true` en el archivo [application.yaml](https://github.com/hapifhir/hapi-fhir-jpaserver-starter/blob/master/src/main/resources/application.yaml) para habilitar [Clinical Quality Language](https://cql.hl7.org/) en este servidor. Un archivo de configuración alternativo, [application-cds.yaml](https://github.com/hapifhir/hapi-fhir-jpaserver-starter/blob/master/src/main/resources/application-cds.yaml), existe con el módulo Clinical Reasoning habilitado y configuraciones predeterminadas que se ha encontrado que funcionan con la mayoría de casos de prueba CDS y dQM.

## Habilitar CDS Hooks

Establece `hapi.fhir.cdshooks.enabled=true` en el archivo [application.yaml](https://github.com/hapifhir/hapi-fhir-jpaserver-starter/blob/master/src/main/resources/application.yaml) para habilitar [CDS Hooks](https://cds-hooks.org/) en este servidor. El módulo Clinical Reasoning también debe estar habilitado porque esta implementación de CDS Hooks incluye [CDS on FHIR](https://build.fhir.org/clinicalreasoning-cds-on-fhir.html). Un ejemplo de servicio CDS usando CDS on FHIR está disponible en la clase de prueba CdsHooksServletIT.

## Habilitar MDM (EMPI)

Establece `hapi.fhir.mdm_enabled=true` en el archivo [application.yaml](https://github.com/hapifhir/hapi-fhir-jpaserver-starter/blob/master/src/main/resources/application.yaml) para habilitar MDM en este servidor. Las reglas de coincidencia MDM se configuran en [mdm-rules.json](https://github.com/hapifhir/hapi-fhir-jpaserver-starter/blob/master/src/main/resources/mdm-rules.json). Las reglas en este archivo de ejemplo deben reemplazarse con reglas de coincidencia reales apropiadas para tus datos. Ten en cuenta que MDM depende de las suscripciones, por lo que para que MDM funcione, las suscripciones deben estar habilitadas.

## Usar Elasticsearch

Por defecto, el servidor usará índices lucene embebidos para propósitos de terminología e indexación de texto completo. Puedes cambiar esto para usar lucene editando las propiedades en [application.yaml](https://github.com/hapifhir/hapi-fhir-jpaserver-starter/blob/master/src/main/resources/application.yaml)

Por ejemplo:

```properties
elasticsearch.enabled=true
elasticsearch.rest_url=localhost:9200
elasticsearch.username=SomeUsername
elasticsearch.password=SomePassword
elasticsearch.protocol=http
elasticsearch.required_index_status=YELLOW
elasticsearch.schema_management_strategy=CREATE
```

## Habilitar LastN

Establece `hapi.fhir.lastn_enabled=true` en el archivo [application.yaml](https://github.com/hapifhir/hapi-fhir-jpaserver-starter/blob/master/src/main/resources/application.yaml) para habilitar la operación $lastn en este servidor. Ten en cuenta que la operación $lastn depende de Elasticsearch, por lo que para que $lastn funcione, la indexación debe estar habilitada usando Elasticsearch.

## Habilitar almacenamiento de recursos en Índice Lucene

Establece `hapi.fhir.store_resource_in_lucene_index_enabled` en el archivo [application.yaml](https://github.com/hapifhir/hapi-fhir-jpaserver-starter/blob/master/src/main/resources/application.yaml) para habilitar el almacenamiento de json de recursos junto con los mapeos de índice Lucene/Elasticsearch.

## Cambiar tiempo de resultados de búsqueda en caché

Es posible cambiar el tiempo de resultados de búsqueda en caché. La opción `reuse_cached_search_results_millis` en el [application.yaml](https://github.com/hapifhir/hapi-fhir-jpaserver-starter/blob/master/src/main/resources/application.yaml) es 6000 milisegundos por defecto.
Establece `reuse_cached_search_results_millis: -1` en el archivo [application.yaml](https://github.com/hapifhir/hapi-fhir-jpaserver-starter/blob/master/src/main/resources/application.yaml) para ignorar el tiempo de caché en cada búsqueda.

## Construir la variante distroless de la imagen (para menor huella y seguridad mejorada)

El Dockerfile predeterminado contiene una etapa `release-distroless` para construir una variante de la imagen
usando la imagen base `gcr.io/distroless/java-debian10:11`:

```sh
docker build --target=release-distroless -t hapi-fhir:distroless .
```

Ten en cuenta que las imágenes distroless también se construyen y publican automáticamente en el registro de contenedores,
ve el sufijo `-distroless` en las etiquetas de imagen.

## Agregar operaciones personalizadas

Para agregar una operación personalizada, consulta la documentación en las librerías principales de hapi-fhir [aquí](https://hapifhir.io/hapi-fhir/docs/server_plain/rest_operations_operations.html).

Dentro de `hapi-fhir-jpaserver-starter`, crea una clase genérica (que no extienda o implemente ninguna clase o interfaz), agrega la `@Operation` como un método dentro de la clase genérica, y luego registra la clase como un proveedor usando `RestfulServer.registerProvider()`.

## Instalación de paquete en tiempo de ejecución

Es posible instalar un paquete de Guía de Implementación FHIR (`package.tgz`) ya sea desde un paquete publicado o desde un paquete local con la operación `$install`, sin tener que reiniciar el servidor. Esto está disponible para R4 y R5.

Esta característica debe estar habilitada en el application.yaml (o línea de comandos de docker):

```yaml
hapi:
  fhir:
    ig_runtime_upload_enabled: true
```

La operación `$install` se activa con un POST a `[server]/ImplementationGuide/$install`, con la carga útil a continuación:

```json
{
  "resourceType": "Parameters",
  "parameter": [
    {
      "name": "npmContent",
      "valueBase64Binary": "[BASE64_ENCODED_NPM_PACKAGE_DATA]"
    }
  ]
}
```

## Habilitar auto-instrumentación OpenTelemetry

La imagen del contenedor incluye el JAR del agente Java de [OpenTelemetry Java auto-instrumentation](https://github.com/open-telemetry/opentelemetry-java-instrumentation)
que puede usarse para exportar datos de telemetría para el Servidor HAPI FHIR JPA. Puedes habilitarlo especificando la bandera `-javaagent`,
por ejemplo, anulando la variable de entorno `JAVA_TOOL_OPTIONS`:

```sh
docker run --rm -it -p 8080:8080 \
  -e JAVA_TOOL_OPTIONS="-javaagent:/app/opentelemetry-javaagent.jar" \
  -e OTEL_TRACES_EXPORTER="jaeger" \
  -e OTEL_SERVICE_NAME="hapi-fhir-server" \
  -e OTEL_EXPORTER_JAEGER_ENDPOINT="http://jaeger:14250" \
  docker.io/hapiproject/hapi:latest
```

Puedes configurar el agente usando variables de entorno o propiedades del sistema Java, ve <https://opentelemetry.io/docs/instrumentation/java/automatic/agent-config/> para detalles.

## Habilitar MCP

Las capacidades MCP pueden habilitarse estableciendo `spring.ai.mcp.server.enabled` a `true`. Esto habilitará el servidor MCP y expondrá los endpoints MCP. El endpoint MCP está actualmente codificado como `/mcp/message` y puede probarse ejecutando, por ejemplo, `npx @modelcontextprotocol/inspector` y conectarse a http://localhost:8080/mcp/message usando Streamable HTTP. Spring AI MCP Server Auto Configuration no está actualmente soportado.
