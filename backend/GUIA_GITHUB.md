# 🚀 Guía: Subir y Transferir Proyecto con GitHub

## ✅ Sí, GitHub es la MEJOR forma de transferir el proyecto

**Ventajas**:
- ✅ Transferencia completa y confiable
- ✅ Control de versiones automático
- ✅ Respaldo en la nube
- ✅ Historial de cambios
- ✅ Sincronización entre laptops

---

## 📋 Paso 1: Preparar el Proyecto en Esta Laptop

### Verificar que .gitignore está correcto

```powershell
# El .gitignore ya está actualizado con:
# - Flutter (build/, .dart_tool/, etc.)
# - Backups (mvnw.cmd.backup)
# - Variables de entorno (.env, application-secrets.yaml)
# - Archivos compilados (target/, *.class)

# Verificar contenido:
Get-Content .gitignore | Select-String "Flutter|maven|backup"
```

### ⚠️ IMPORTANTE: Qué SÍ se subirá (y debe subirse)

```
✅ .mvn/wrapper/maven-wrapper.jar (61.5 KB) - ¡LO REPARAMOS!
✅ mvnw.cmd - ¡LO REPARAMOS!
✅ flutter_frontend/lib/ - Todo el código Dart
✅ flutter_frontend/update-ip.ps1 - Script importante
✅ src/main/java/ - Todo el código Java
✅ src/test/java/ - Todos los tests
✅ pom.xml - Dependencias Maven
✅ docker-compose.yml - Configuración de BD
✅ Archivos de documentación (.md)
✅ .github/copilot-instructions.md - Para Copilot
```

### ⚠️ Qué NO se subirá (ignorado por .gitignore)

```
❌ target/ - Archivos compilados (se regeneran)
❌ flutter_frontend/build/ - Build de Flutter
❌ flutter_frontend/.dart_tool/ - Cache de Dart
❌ mvnw.cmd.backup - Backup del archivo corrupto
❌ .env - Variables de entorno (si las creas)
❌ *.class, *.jar (excepto maven-wrapper.jar)
❌ .idea/ - Configuración de IntelliJ
❌ .vscode/settings.json - Configuración personal
```

---

## 🚀 Paso 2: Subir a GitHub (Primera Vez)

### Opción A: Crear Repo desde GitHub Web (Recomendado)

**1. Crear repositorio en GitHub:**
```
1. Ve a: https://github.com/new
2. Repository name: hapi-fhir-hospital-system
3. Description: Sistema de gestión hospitalaria FHIR con autenticación JWT y Flutter
4. ⚠️ NO marcar "Initialize with README" (ya tienes archivos)
5. ⚠️ NO agregar .gitignore (ya tienes uno)
6. Público o Privado (recomiendo Privado si tiene datos sensibles)
7. Click "Create repository"
```

**2. En tu laptop, conectar con GitHub:**
```powershell
# En el directorio del proyecto
cd C:\Users\ulise\Desktop\hapi-fhir-jpaserver-starter

# Inicializar Git (si no está inicializado)
git init

# Ver qué archivos se subirán
git status
# Debe mostrar muchos archivos en verde/rojo

# Ver qué archivos están siendo ignorados
git status --ignored
# Debe incluir target/, build/, etc.

# Agregar todos los archivos (excepto los ignorados)
git add .

# Ver estado de nuevo (todo debe estar en verde)
git status

# Crear primer commit
git commit -m "Initial commit: HAPI FHIR + Custom Auth + Flutter + Docs"

# Agregar tu repositorio remoto (cambia TU_USUARIO)
git remote add origin https://github.com/TU_USUARIO/hapi-fhir-hospital-system.git

# Subir a GitHub
git branch -M main
git push -u origin main
```

**3. Autenticación:**

Si pide usuario/contraseña:
```
Username: TU_USUARIO_GITHUB
Password: [USAR PERSONAL ACCESS TOKEN, NO PASSWORD]
```

**Crear Personal Access Token:**
1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. "Generate new token (classic)"
3. Nombre: "Laptop Transfer Token"
4. Scopes: ✅ repo (todos los permisos de repositorio)
5. "Generate token"
6. **COPIAR TOKEN** (solo se muestra una vez)
7. Usarlo como password en git push

### Opción B: Usar GitHub CLI (Más rápido)

```powershell
# Instalar GitHub CLI
winget install GitHub.cli

# Autenticar
gh auth login
# Seleccionar: GitHub.com → HTTPS → Yes → Login with web browser

# Crear repositorio y subir
cd C:\Users\ulise\Desktop\hapi-fhir-jpaserver-starter
git init
git add .
git commit -m "Initial commit: HAPI FHIR + Custom Auth + Flutter + Docs"
gh repo create hapi-fhir-hospital-system --private --source=. --push
```

---

## 📥 Paso 3: Descargar en Nueva Laptop

### Configuración Inicial en Nueva Laptop

```powershell
# 1. Instalar Git (si no está instalado)
winget install Git.Git

# 2. Configurar Git
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"

# 3. Autenticar con GitHub
# Opción A: GitHub CLI
winget install GitHub.cli
gh auth login

# Opción B: Personal Access Token
# Usar el mismo token que generaste antes
```

### Clonar el Repositorio

```powershell
# Navegar a Desktop
cd C:\Users\<TU_NUEVO_USUARIO>\Desktop

# Clonar repositorio
git clone https://github.com/TU_USUARIO/hapi-fhir-hospital-system.git

# Renombrar carpeta (opcional, para mantener mismo nombre)
Rename-Item hapi-fhir-hospital-system hapi-fhir-jpaserver-starter

# Entrar al proyecto
cd hapi-fhir-jpaserver-starter
```

### Verificar que Todo se Descargó

```powershell
# Verificar archivos críticos
Test-Path .\.mvn\wrapper\maven-wrapper.jar
# Debe retornar True

Test-Path .\mvnw.cmd
# Debe retornar True

Test-Path .\flutter_frontend\update-ip.ps1
# Debe retornar True

Test-Path .\CONTEXTO_PARA_NUEVA_SESION.md
# Debe retornar True

# Ver estadísticas
Get-ChildItem -Recurse -File | Measure-Object | Select-Object Count
# Debe mostrar varios miles de archivos
```

---

## ⚙️ Paso 4: Configurar en Nueva Laptop

### 1. Actualizar IP de Red

```powershell
cd flutter_frontend
.\update-ip.ps1
```

### 2. Instalar Dependencias

```powershell
# Flutter
cd flutter_frontend
flutter pub get
cd ..

# Maven (se descargará automáticamente al ejecutar mvnw)
# No necesitas hacer nada
```

### 3. Iniciar Docker

```powershell
docker-compose up -d
```

### 4. Verificar que Funciona

```powershell
# Backend
.\mvnw.cmd spring-boot:run -Pboot

# En otra terminal: Frontend
cd flutter_frontend
flutter run -d chrome

# En otra terminal: Tests
.\mvnw.cmd test -Dtest="Auth*,User*"
```

---

## 🔄 Sincronizar Cambios Entre Laptops

### Desde Laptop 1 (después de hacer cambios):

```powershell
# Ver qué cambió
git status

# Agregar cambios
git add .

# Commit con mensaje descriptivo
git commit -m "feat: Agregado endpoint para cambiar contraseña"

# Subir a GitHub
git push
```

### En Laptop 2 (para obtener cambios):

```powershell
# Descargar últimos cambios
git pull

# Si modificaste archivos de configuración local (como IP):
# Git puede mostrar conflictos, resuelve manualmente o:
git stash          # Guarda cambios locales temporalmente
git pull           # Descarga cambios
git stash pop      # Recupera cambios locales
```

---

## 📁 Estructura de Ramas (Recomendado)

Para trabajar de forma más organizada:

```powershell
# Rama principal (main/master)
# → Código estable, funcionando

# Rama de desarrollo
git checkout -b dev
# → Aquí haces cambios experimentales

# Ramas de features
git checkout -b feature/cambiar-password
# → Una rama por cada característica nueva

# Cuando terminas un feature:
git checkout dev
git merge feature/cambiar-password
git push origin dev

# Cuando dev está estable:
git checkout main
git merge dev
git push origin main
```

---

## 🔐 Seguridad: Variables de Entorno

**Problema**: No queremos subir secrets a GitHub.

**Solución**: Usar variables de entorno.

### Crear archivo .env (NO se subirá)

```properties
# .env (en la raíz del proyecto)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=fhirdb
DB_USER=admin
DB_PASSWORD=admin
JWT_SECRET=tu-secreto-super-seguro-aqui
JWT_EXPIRATION=86400000
```

### Modificar application.yaml para usar variables

```yaml
# src/main/resources/application.yaml
spring:
  datasource:
    url: jdbc:postgresql://${DB_HOST:localhost}:${DB_PORT:5432}/${DB_NAME:fhirdb}
    username: ${DB_USER:admin}
    password: ${DB_PASSWORD:admin}

jwt:
  secret: ${JWT_SECRET:fallback-secret-only-for-dev}
  expiration: ${JWT_EXPIRATION:86400000}
```

### Crear plantilla .env.example (SÍ se sube)

```properties
# .env.example
# Copiar este archivo a .env y completar con valores reales

DB_HOST=localhost
DB_PORT=5432
DB_NAME=fhirdb
DB_USER=tu_usuario_aqui
DB_PASSWORD=tu_password_aqui
JWT_SECRET=generar_con_openssl_rand_base64_64
JWT_EXPIRATION=86400000
```

Luego en nueva laptop:
```powershell
cp .env.example .env
# Editar .env con valores reales
```

---

## 🚨 Problemas Comunes y Soluciones

### Problema 1: "Maven wrapper jar not found"

**Causa**: .gitignore estaba ignorando maven-wrapper.jar

**Solución**: Ya está arreglado, el .gitignore actualizado NO ignora maven-wrapper.jar

**Verificar**:
```powershell
git ls-files .mvn/wrapper/maven-wrapper.jar
# Debe mostrar la ruta (significa que está incluido en Git)
```

### Problema 2: "Flutter pubspec.lock conflicts"

**Causa**: pubspec.lock difiere entre versiones de Flutter

**Solución**:
```powershell
cd flutter_frontend
flutter pub get
git add pubspec.lock
git commit -m "chore: Update pubspec.lock"
```

### Problema 3: Archivos de configuración personal suben a Git

**Síntoma**: Tu IP, rutas personales, etc. aparecen en Git

**Solución**:
```powershell
# Dejar de rastrear archivo (pero conservarlo localmente)
git rm --cached flutter_frontend/lib/config/api_config.dart
git commit -m "chore: Stop tracking api_config.dart"

# Agregar a .gitignore
echo "flutter_frontend/lib/config/api_config.dart" >> .gitignore

# Crear plantilla
cp flutter_frontend/lib/config/api_config.dart flutter_frontend/lib/config/api_config.example.dart
git add flutter_frontend/lib/config/api_config.example.dart
```

### Problema 4: Target/build suben a Git (repo muy pesado)

**Síntoma**: `git status` muestra target/ o build/

**Solución**:
```powershell
# Eliminar de Git (pero conservar localmente)
git rm -r --cached target
git rm -r --cached flutter_frontend/build
git commit -m "chore: Remove build artifacts from Git"

# Verificar que .gitignore los ignora
cat .gitignore | Select-String "target|build"
```

---

## 📊 Comandos Git Útiles

```powershell
# Ver estado actual
git status

# Ver historial de commits
git log --oneline --graph --all

# Ver qué archivos están siendo ignorados
git status --ignored

# Ver diferencias antes de commit
git diff

# Ver qué archivos están en el repositorio
git ls-files

# Ver tamaño del repositorio
git count-objects -vH

# Deshacer último commit (mantener cambios)
git reset --soft HEAD~1

# Deshacer último commit (eliminar cambios)
git reset --hard HEAD~1

# Ver ramas
git branch -a

# Cambiar de rama
git checkout nombre-rama

# Crear y cambiar a nueva rama
git checkout -b nombre-nueva-rama

# Ver archivos que cambiaron entre commits
git diff --name-only HEAD HEAD~1

# Buscar texto en todo el historial
git log -S "texto_a_buscar" --source --all

# Ver quién modificó cada línea de un archivo
git blame archivo.java
```

---

## ✅ Checklist Final

### En Laptop Actual (antes de transferir):

```
✅ .gitignore actualizado
✅ git init ejecutado
✅ git add . ejecutado
✅ git commit creado
✅ Repositorio creado en GitHub
✅ git push exitoso
✅ Verificar en GitHub web que archivos están ahí
✅ Verificar que maven-wrapper.jar se subió (61.5 KB en .mvn/wrapper/)
✅ Verificar que mvnw.cmd se subió
✅ Verificar que documentación (.md) se subió
```

### En Nueva Laptop:

```
✅ Git instalado
✅ GitHub autenticado (gh auth login o token)
✅ Repositorio clonado
✅ maven-wrapper.jar presente (Test-Path)
✅ mvnw.cmd presente
✅ update-ip.ps1 presente
✅ flutter pub get ejecutado
✅ IP actualizada con update-ip.ps1
✅ docker-compose up -d
✅ Backend inicia sin errores
✅ Frontend inicia sin errores
✅ Tests pasan (23/23 backend, 25/25 frontend)
```

---

## 🎊 ¡Listo!

Usar GitHub para transferir es la mejor opción porque:

1. ✅ **No pierdes nada**: Todos los archivos importantes se transfieren
2. ✅ **Control de versiones**: Puedes volver a cualquier punto del desarrollo
3. ✅ **Sincronización**: Trabajar entre laptops es fácil (pull/push)
4. ✅ **Respaldo**: Tu código está seguro en la nube
5. ✅ **Colaboración**: Si luego trabajas con otros, ya está listo

**Tiempo estimado**:
- Subir a GitHub: 5-10 minutos
- Clonar en nueva laptop: 2-5 minutos
- Configurar (IP, Docker, Flutter): 10-15 minutos
- **Total**: ~20-30 minutos

---

**Repositorio recomendado en GitHub**:
```
Nombre: hapi-fhir-hospital-system
Descripción: Sistema de gestión hospitalaria FHIR con autenticación JWT y Flutter
Visibilidad: Privado (recomendado)
Topics: java, spring-boot, hapi-fhir, flutter, jwt, postgresql, healthcare
```

---

*Última actualización: 21 de Febrero, 2026*  
*Método recomendado para transferencia de proyecto*
