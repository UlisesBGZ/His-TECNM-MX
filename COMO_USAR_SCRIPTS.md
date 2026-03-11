# 🚀 Scripts de Iniciación - Hospital FHIR System

## 📋 Scripts Disponibles

### 1️⃣ `iniciar-sistema.bat` - Inicia TODO el sistema
**Uso**: Doble clic o `.\iniciar-sistema.bat`

**Qué hace**:
- ✅ Inicia PostgreSQL en Docker
- ✅ Inicia Backend en nueva ventana
- ✅ Inicia Frontend en nueva ventana

**Ventanas creadas**:
- `Backend - MANTENER ABIERTO` ← **NO CERRAR** esta ventana
- `Frontend - Puedes cerrar cuando quieras` ← Puedes cerrar sin problema

---

### 2️⃣ `iniciar-backend.bat` - Solo Backend
**Uso**: Doble clic o `.\iniciar-backend.bat`

**Qué hace**:
- ✅ Verifica y libera puerto 8080
- ✅ Inicia PostgreSQL si no está corriendo
- ✅ Inicia Backend Spring Boot

**⚠️ IMPORTANTE**: Esta ventana debe permanecer ABIERTA
- El backend corre en esta ventana
- Para detenerlo: Presiona `Ctrl+C` o cierra la ventana

---

### 3️⃣ `iniciar-frontend.bat` - Solo Frontend
**Uso**: Doble clic o `.\iniciar-frontend.bat`

**Qué hace**:
- ✅ Verifica que el backend esté corriendo
- ✅ Inicia Flutter en Chrome

**Ventaja**: Puedes cerrar y reabrir el frontend cuantas veces quieras
- El backend seguirá corriendo
- Solo ejecuta este script para reabrir el frontend

---

### 4️⃣ `detener-sistema.bat` - Detiene TODO
**Uso**: Doble clic o `.\detener-sistema.bat`

**Qué hace**:
- 🛑 Detiene todos los procesos Java (Backend)
- 🛑 Detiene todos los procesos Flutter (Frontend)
- 🛑 Detiene PostgreSQL en Docker

---

## 🎯 Flujos de Trabajo Recomendados

### Flujo 1: Desarrollo Normal (usar una vez al día)
```powershell
# Al iniciar tu día de desarrollo
.\iniciar-sistema.bat

# NO cierres la ventana del Backend
# Usa el sistema normalmente
# Puedes cerrar el Frontend cuando quieras

# Al terminar el día
.\detener-sistema.bat
```

### Flujo 2: Backend siempre corriendo
```powershell
# Iniciar backend (dejar corriendo)
.\iniciar-backend.bat

# En otra terminal, cuando necesites el frontend
.\iniciar-frontend.bat

# Cerrar frontend cuando no lo uses
# (simplemente cierra la ventana)

# Volver a abrir frontend
.\iniciar-frontend.bat

# Al terminar el día
.\detener-sistema.bat
```

### Flujo 3: Solo probar cambios del Frontend
```powershell
# Si el backend ya está corriendo
# Solo ejecuta:
.\iniciar-frontend.bat

# Cierra el frontend
# Haz cambios en el código
# Vuelve a ejecutar:
.\iniciar-frontend.bat
```

---

## 🆘 Solución de Problemas

### Error: "Puerto 8080 ya en uso"
**Solución 1**: Ejecuta `.\detener-sistema.bat`
**Solución 2**: Detén contenedores Docker que usen 8080:
```powershell
docker ps
docker stop <nombre-del-contenedor>
```

### Error: "Backend no está respondiendo"
**Causa**: El backend no está corriendo
**Solución**: Ejecuta `.\iniciar-backend.bat` primero

### PostgreSQL no inicia
**Causa**: Docker Desktop no está corriendo
**Solución**: Abre Docker Desktop y espera que inicie

---

## 🔐 Credenciales de Desarrollo

**Usuario Admin**:
- Username: `admin`
- Password: `admin123`

**Base de Datos**:
- Host: `localhost:5432`
- Database: `fhirdb`
- Usuario: `admin`
- Password: `admin`

---

## 📚 Más Información

- [README.md](README.md) - Documentación completa del proyecto
- [backend/CONTEXTO_PARA_NUEVA_SESION.md](backend/CONTEXTO_PARA_NUEVA_SESION.md) - Contexto técnico detallado
