# ✅ CHECKLIST DE TRANSFERENCIA A NUEVA LAPTOP

## 📦 PASO 1: ARCHIVOS A COPIAR

### ⭐ MÉTODO RECOMENDADO: Usar GitHub

**Es la forma MÁS FÁCIL y CONFIABLE** de transferir el proyecto:

```powershell
# En tu laptop actual:
.\subir-a-github.ps1

# En tu nueva laptop:
git clone https://github.com/TU_USUARIO/hapi-fhir-hospital-system.git
```

**Ventajas**:
- ✅ No pierdes ningún archivo
- ✅ Control de versiones automático
- ✅ Respaldo en la nube
- ✅ Sincronización entre laptops
- ✅ No necesitas USB ni red local

**📚 Ver guía completa**: [GUIA_GITHUB.md](GUIA_GITHUB.md)

---

### Método Alternativo: Copiar Carpeta Completa
```
✅ Copiar toda la carpeta: hapi-fhir-jpaserver-starter/
```

### Verificar Archivos Críticos (IMPORTANTE)
Antes de cerrar esta laptop, verificar que estos archivos estén presentes:

```
📂 Raíz del proyecto:
  ✅ mvnw.cmd (NO el .backup)
  ✅ pom.xml
  ✅ docker-compose.yml
  ✅ DESARROLLO_COMPLETO.md
  ✅ CONTEXTO_PARA_NUEVA_SESION.md
  ✅ PROMPT_PARA_NUEVA_IA.md
  ✅ AGENTS.md

📂 .mvn/wrapper/:
  ✅ maven-wrapper.jar (61.5 KB) ← MUY IMPORTANTE (incluido en repo, NO descargar)
  ✅ maven-wrapper.properties

📂 src/main/java/ca/uhn/fhir/jpa/starter/:
  ✅ Application.java
  ✅ auth/ (toda la carpeta con controllers, services, security)

📂 src/test/java/ca/uhn/fhir/jpa/starter/auth/:
  ✅ AuthControllerTest.java
  ✅ UserControllerTest.java

📂 flutter_frontend/:
  ✅ lib/ (toda la carpeta)
  ✅ test/ (toda la carpeta)
  ✅ pubspec.yaml
  ✅ update-ip.ps1 ← IMPORTANTE para actualizar IP
  ✅ android/ (toda la carpeta)

📂 src/main/resources/:
  ✅ application.yaml
  ✅ application-cds.yaml
  ✅ application-elastic.yaml
```

### NO Copiar (opcional, se regeneran)
```
❌ target/ (se regenera con mvnw)
❌ flutter_frontend/build/ (se regenera con flutter)
❌ flutter_frontend/.dart_tool/ (se regenera)
❌ mvnw.cmd.backup (es backup del archivo corrupto)
❌ .idea/ (configuración IDE, opcional)
```

---

## 🔧 PASO 2: REQUISITOS EN NUEVA LAPTOP

### Software a Instalar

```powershell
# 1. Java (JDK 17 o superior) - Verificado: 21.0.10
# Descargar de: https://adoptium.net/
java -version
# Debe mostrar: openjdk version "21.0.10" o superior

# 2. Flutter (3.27 o superior) - Verificado: 3.27.3
# Descargar de: https://docs.flutter.dev/get-started/install
flutter --version
# Debe mostrar: Flutter 3.27.3 o superior

# 3. Docker Desktop
# Descargar de: https://www.docker.com/products/docker-desktop/
docker --version
# Debe mostrar: Docker version 20+ o superior

# 4. Git (opcional pero recomendado)
git --version
```

### Variables de Entorno (si no detecta comandos)

**Java**:
```
JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.x.x
PATH=%JAVA_HOME%\bin;%PATH%
```

**Flutter**:
```
PATH=C:\src\flutter\bin;%PATH%
```

---

## 🚀 PASO 3: CONFIGURACIÓN EN NUEVA LAPTOP

### 1. Copiar Proyecto

```powershell
# Pegar la carpeta en:
C:\Users\<TU_NUEVO_USUARIO>\Desktop\hapi-fhir-jpaserver-starter\
```

### 2. Actualizar IP de Red (CRÍTICO para móvil)

```powershell
cd C:\Users\<TU_NUEVO_USUARIO>\Desktop\hapi-fhir-jpaserver-starter\flutter_frontend

# Ver tu nueva IP
ipconfig | Select-String "IPv4"
# Anota tu IP local (ej: 192.168.x.x)

# Actualizar automáticamente
.\update-ip.ps1
```

**Resultado esperado**:
```
✅ IP encontrada: 192.168.X.X
📝 Actualizando de 192.168.21.0 a 192.168.X.X...
✅ lib/config/api_config.dart actualizado
✅ lib/services/fhir_service.dart actualizado
```

### 3. Iniciar Base de Datos

```powershell
cd C:\Users\<TU_NUEVO_USUARIO>\Desktop\hapi-fhir-jpaserver-starter

docker-compose up -d

# Verificar que está corriendo
docker ps
# Debe mostrar: hapi-fhir-postgres ... Up ... (healthy)
```

### 4. Iniciar Backend

```powershell
# En el mismo directorio
.\mvnw.cmd spring-boot:run -Pboot

# Esperar mensaje:
# "Started Application in X seconds (JVM running for Y)"
```

### 5. Iniciar Frontend (Web)

```powershell
# Abrir NUEVA terminal PowerShell
cd C:\Users\<TU_NUEVO_USUARIO>\Desktop\hapi-fhir-jpaserver-starter\flutter_frontend

flutter pub get

flutter run -d chrome

# Chrome se abrirá automáticamente
```

### 6. Probar Login

- Usuario: `admin`
- Contraseña: `admin123`

**Si funciona** ✅ → ¡Sistema listo!

---

## 🧪 PASO 4: VERIFICAR INTEGRIDAD

### Tests del Backend

```powershell
cd C:\Users\<TU_NUEVO_USUARIO>\Desktop\hapi-fhir-jpaserver-starter

.\mvnw.cmd test -Dtest="AuthControllerTest,UserControllerTest"
```

**Resultado esperado**:
```
Tests run: 23, Failures: 0, Errors: 0, Skipped: 0
BUILD SUCCESS
```

### Tests del Frontend

```powershell
cd flutter_frontend

flutter test
```

**Resultado esperado**:
```
00:12 +25: All tests passed!
```

---

## 🤖 PASO 5: CONTEXTO PARA NUEVA SESIÓN DE IA

### Opción 1: Archivo Completo (Recomendado)

1. Abrir: `CONTEXTO_PARA_NUEVA_SESION.md`
2. Leer completamente para entender el proyecto
3. Usar como referencia cuando trabajes

### Opción 2: Prompt Rápido para IA

1. Abrir: `PROMPT_PARA_NUEVA_IA.md`
2. Copiar TODO el contenido
3. Pegar en una nueva sesión de IA (como esta)
4. Agregar tu petición al final

**Ejemplo**:
```
[PEGAR TODO EL CONTENIDO DE PROMPT_PARA_NUEVA_IA.md]

---

## 💬 PETICIÓN ACTUAL

Necesito agregar un endpoint para actualizar perfil de usuario.
```

---

## 📋 CHECKLIST FINAL

Antes de cerrar la laptop anterior:

```
ARCHIVOS:
  ✅ Proyecto completo copiado a USB/nube/nueva laptop
  ✅ maven-wrapper.jar incluido (.mvn/wrapper/)
  ✅ mvnw.cmd incluido (NO el .backup)
  ✅ update-ip.ps1 incluido (flutter_frontend/)
  ✅ Documentación incluida (3 archivos .md)

DATOS IMPORTANTES:
  ✅ IP actual anotada (si vas a usar móvil): _____________
  ✅ Credenciales recordadas:
      - Admin: admin / admin123
      - BD: admin / admin (localhost:5432/fhirdb)
```

En la laptop nueva:

```
REQUISITOS:
  ✅ Java 17+ instalado y en PATH
  ✅ Flutter 3.38+ instalado y en PATH
  ✅ Docker Desktop instalado y corriendo
  ✅ Git instalado (opcional)

SETUP:
  ✅ Proyecto copiado a Desktop/
  ✅ IP actualizada con update-ip.ps1
  ✅ Docker Compose iniciado
  ✅ Backend corriendo (mvnw.cmd spring-boot:run)
  ✅ Frontend corriendo (flutter run)
  ✅ Login probado (admin/admin123)
  ✅ Tests ejecutados y pasando

DOCUMENTACIÓN:
  ✅ CONTEXTO_PARA_NUEVA_SESION.md leído
  ✅ PROMPT_PARA_NUEVA_IA.md preparado
  ✅ DESARROLLO_COMPLETO.md disponible para referencia
```

---

## 🆘 SI ALGO NO FUNCIONA

### Backend no inicia

```powershell
# Verificar Java
java -version

# Verificar Maven Wrapper
Test-Path .\.mvn\wrapper\maven-wrapper.jar
# Si retorna False, revisar CONTEXTO_PARA_NUEVA_SESION.md
# sección "Maven Wrapper No Funcionaba"

# Verificar BD corriendo
docker ps | Select-String "postgres"

# Verificar puerto libre
Test-NetConnection localhost -Port 8080
# TcpTestSucceeded debe ser False (puerto libre)
```

### Frontend no compila

```powershell
# Limpiar cache
cd flutter_frontend
flutter clean
flutter pub get

# Verificar Flutter
flutter doctor
# Debe mostrar ✓ en Flutter, Android toolchain

# Verificar dependencias
flutter pub outdated
```

### No puedo hacer login en móvil

```powershell
# Verificar IP actualizada
cd flutter_frontend
.\update-ip.ps1

# Verificar misma red WiFi
# PC y móvil deben estar en 192.168.X.X (misma subred)

# Verificar firewall no bloquea puerto 8080
# Windows Defender Firewall → Permitir aplicación

# Ver logs en terminal donde corre backend
# Buscar errores de CORS o autenticación
```

### Tests fallan

```powershell
# Si son tests HAPI (9 errores), es NORMAL
# Ejecutar solo tests custom:
.\mvnw.cmd test -Dtest="AuthControllerTest,UserControllerTest"

# Si tests custom fallan, verificar:
# 1. BD corriendo
# 2. Código sin modificaciones
# 3. maven-wrapper.jar presente
```

---

## 📞 RECURSOS DE AYUDA

**Orden de consulta**:

1. **Este archivo** (CHECKLIST_TRANSFERENCIA.md) - Setup inicial
2. **PROMPT_PARA_NUEVA_IA.md** - Contexto rápido para IA
3. **CONTEXTO_PARA_NUEVA_SESION.md** - Guía completa de setup
4. **DESARROLLO_COMPLETO.md** - Historia detallada y troubleshooting

**Comandos de diagnóstico rápido**:

```powershell
# En nueva laptop, verificar todo:
java -version
flutter --version
docker --version
Test-Path .\.mvn\wrapper\maven-wrapper.jar
Test-Path .\flutter_frontend\update-ip.ps1
docker ps
Test-NetConnection localhost -Port 8080
ipconfig | Select-String "IPv4"
```

---

## ✅ CONFIRMACIÓN FINAL

**Sistema está listo cuando**:

- ✅ `.\mvnw.cmd spring-boot:run` inicia sin errores
- ✅ `docker ps` muestra postgres corriendo
- ✅ `flutter run -d chrome` abre app en Chrome
- ✅ Login con admin/admin123 funciona
- ✅ `.\mvnw.cmd test -Dtest="Auth*,User*"` pasa 23/23 tests
- ✅ `flutter test` pasa 25+ tests

**Tiempo estimado de setup**: 15-20 minutos  
**Dificultad**: Baja (siguiendo este checklist)

---

## 🎉 ¡ÉXITO!

Si llegaste aquí y todos los checks están ✅, entonces:

**🎊 ¡Proyecto transferido exitosamente! 🎊**

Puedes continuar desarrollo normalmente. El sistema está en el mismo estado que en la laptop anterior.

---

*Última actualización: 20 de Febrero, 2026*  
*Versión: 1.0*  
*Creado para facilitar transferencia de proyecto entre laptops*
