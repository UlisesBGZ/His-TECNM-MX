# 🔐 Guía para Iniciar Sesión - Solución de Errores

## ❌ Error Común: "Error de login - Puerto 8080"

Si ves un error de login relacionado con el puerto 8080, significa que **el backend NO está corriendo**.

### 🔍 ¿Por qué pasa esto?

El sistema tiene **DOS partes**:
1. **Backend** (servidor en Java) → Corre en puerto 8080
2. **Frontend** (aplicación Flutter) → Se conecta al puerto 8080

**El problema**: Si solo abres el frontend, este intenta conectarse al backend pero no lo encuentra, causando el error de login.

---

## ✅ Solución: Pasos Correctos para Iniciar Sesión

### Opción 1: Iniciar TODO el Sistema (Recomendado para Principiantes)

1. **Abre Docker Desktop** y espera que inicie completamente

2. **Ejecuta el script de inicio**:
   ```powershell
   .\iniciar-sistema.bat
   ```

3. **Espera a que aparezcan 2 ventanas**:
   - `Backend - MANTENER ABIERTO` (NO cerrar esta ventana)
   - `Frontend - Puedes cerrar cuando quieras`

4. **Espera 30-60 segundos** hasta ver en la ventana del Backend:
   ```
   Started Application in X.XXX seconds
   ```

5. **El navegador se abrirá automáticamente** mostrando la pantalla de login

6. **Inicia sesión con las credenciales**:
   - Usuario: `admin`
   - Contraseña: `admin123`

---

### Opción 2: Iniciar Manualmente (Control Total)

#### Paso 1: Iniciar el Backend

1. Abre PowerShell o CMD en la carpeta del proyecto

2. Ejecuta:
   ```powershell
   .\iniciar-backend.bat
   ```

3. **⚠️ IMPORTANTE**: Esta ventana debe permanecer ABIERTA
   - Verás muchos logs de Spring Boot
   - Espera hasta ver: `Started Application in X.XXX seconds`
   - Si cierras esta ventana, el backend se detiene

#### Paso 2: Verificar que el Backend está Corriendo

Abre tu navegador y visita:
```
http://localhost:8080/fhir/metadata
```

**✅ Si funciona**: Verás un JSON con información del servidor FHIR

**❌ Si NO funciona**: El backend no está corriendo o hay un problema

#### Paso 3: Iniciar el Frontend

1. **En otra terminal** (mantén la del backend abierta), ejecuta:
   ```powershell
   .\iniciar-frontend.bat
   ```

2. El navegador se abrirá automáticamente

3. Inicia sesión:
   - Usuario: `admin`
   - Contraseña: `admin123`

---

## 🆘 Solución de Problemas Específicos

### Problema 1: "Puerto 8080 ya está en uso"

**Causa**: Otro programa está usando el puerto 8080

**Solución A** - Detener todo y reiniciar:
```powershell
.\detener-sistema.bat
# Espera 5 segundos
.\iniciar-sistema.bat
```

**Solución B** - Buscar qué está usando el puerto:
```powershell
netstat -ano | findstr :8080
```
Esto te mostrará el PID (número de proceso). Luego deténlo:
```powershell
taskkill /PID <número-del-pid> /F
```

**Solución C** - Detener contenedores Docker que usen 8080:
```powershell
docker ps
docker stop <nombre-del-contenedor>
```

---

### Problema 2: "Backend no responde" o "Connection refused"

**Verificación Rápida**:
```powershell
# Ver si el backend está corriendo
curl http://localhost:8080/fhir/metadata
```

**Si no funciona**:

1. **Verifica Docker Desktop**:
   - Debe estar abierto y corriendo
   - PostgreSQL necesita Docker

2. **Revisa la ventana del Backend**:
   - ¿Está abierta la ventana `Backend - MANTENER ABIERTO`?
   - ¿Muestra errores en rojo?
   - ¿Dice "Started Application"?

3. **Reinicia el Backend**:
   ```powershell
   # Si está corriendo, cierra la ventana o presiona Ctrl+C
   # Luego ejecuta de nuevo:
   .\iniciar-backend.bat
   ```

---

### Problema 3: "Error al conectar con la base de datos"

**Causa**: PostgreSQL en Docker no está corriendo

**Solución**:
```powershell
# Verificar si el contenedor está corriendo
docker ps

# Si no ves postgres-hospital, inícialo:
cd backend
docker-compose up -d postgres
```

**Verificar que PostgreSQL responde**:
```powershell
# Ver logs de PostgreSQL
docker logs postgres-hospital

# Debería decir "database system is ready to accept connections"
```

---

### Problema 4: "Invalid username or password" (Credenciales incorrectas)

**Credenciales correctas**:
- **Usuario**: `admin` (todo en minúsculas)
- **Contraseña**: `admin123` (exactamente así)

**Si aún no funciona**:

1. **Verifica que el usuario admin existe en la BD**:
   ```powershell
   # Conéctate a PostgreSQL
   docker exec -it postgres-hospital psql -U admin -d fhirdb
   
   # Dentro de PostgreSQL, ejecuta:
   SELECT id, username, role FROM users;
   
   # Deberías ver el usuario 'admin'
   # Para salir: \q
   ```

2. **Si el usuario admin NO existe**, créalo:
   - Detén el backend (Ctrl+C en su ventana)
   - Borra el volumen de Docker:
     ```powershell
     docker-compose down -v
     docker-compose up -d postgres
     ```
   - Inicia el backend de nuevo:
     ```powershell
     .\iniciar-backend.bat
     ```
   - El script `init-admin.sql` creará el usuario automáticamente

---

## 🎯 Checklist de Inicio Sesión Exitoso

Antes de intentar iniciar sesión, verifica:

- [ ] **Docker Desktop está corriendo** (icono en la bandeja del sistema)
- [ ] **Backend está iniciado** (ventana abierta con logs)
- [ ] **Backend muestra "Started Application"** (mensaje exitoso)
- [ ] **Puerto 8080 está libre** (solo el backend lo usa)
- [ ] **PostgreSQL está corriendo** (`docker ps` muestra postgres-hospital)
- [ ] **Frontend se abre en el navegador** (localhost:xxxx)
- [ ] **Usas las credenciales correctas** (admin / admin123)

---

## 🔧 Verificación Completa del Sistema

Si nada funciona, ejecuta esta verificación completa:

```powershell
# 1. Detener todo
.\detener-sistema.bat

# 2. Verificar que nada está corriendo
docker ps
# Debe estar vacío o sin contenedores del proyecto

netstat -ano | findstr :8080
# No debe mostrar nada (puerto libre)

# 3. Iniciar desde cero
.\iniciar-sistema.bat

# 4. Esperar 60 segundos completos

# 5. Verificar backend
curl http://localhost:8080/fhir/metadata
# Debe devolver un JSON

# 6. Si el frontend no se abrió automáticamente:
.\iniciar-frontend.bat

# 7. Iniciar sesión con: admin / admin123
```

---

## 📱 Nota para Dispositivos Móviles (Android)

Si ejecutas la app en un **teléfono Android**, necesitas configurar la IP:

1. **Encuentra tu IP en la PC** donde corre el backend:
   ```powershell
   ipconfig | Select-String "IPv4"
   ```
   
   Busca la línea que dice algo como: `192.168.0.XXX`

2. **Edita el archivo de configuración del frontend**:
   - Archivo: `frontend/lib/config/api_config.dart`
   - Línea 9: Cambia la IP a la de tu PC:
     ```dart
     static const String _mobileBaseUrl = 'http://TU_IP_AQUI:8080';
     ```

3. **Asegúrate que**:
   - La PC y el teléfono estén en la **misma red WiFi**
   - El **firewall de Windows** permita conexiones en el puerto 8080

---

## 💡 Consejos de Desarrollo

### Flujo Diario Recomendado:

**Al iniciar el día**:
```powershell
.\iniciar-backend.bat
# Deja esta ventana abierta todo el día
```

**Cuando necesites el frontend**:
```powershell
.\iniciar-frontend.bat
```

**Puedes cerrar el frontend** cuando quieras y volver a abrirlo sin problemas.

**Al terminar el día**:
```powershell
.\detener-sistema.bat
```

---

## 📞 Contacto y Reportar Problemas

Si sigues teniendo problemas:

1. **Captura una foto del error** (pantalla completa)
2. **Copia los últimos 20 líneas de la ventana del Backend**
3. **Ejecuta estos comandos** y guarda la salida:
   ```powershell
   docker ps
   netstat -ano | findstr :8080
   curl http://localhost:8080/fhir/metadata
   ```

4. **Comparte la información** con el desarrollador del proyecto

---

## 📚 Documentación Relacionada

- [README.md](README.md) - Documentación completa del proyecto
- [COMO_USAR_SCRIPTS.md](COMO_USAR_SCRIPTS.md) - Guía detallada de scripts
- [backend/README.md](backend/README.md) - Documentación técnica del backend
- [frontend/README.md](frontend/README.md) - Documentación del frontend

---

## ⚖️ Licencia

Apache License 2.0 - Ver [LICENSE](LICENSE)
