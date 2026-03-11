# 🏥 GUÍA RÁPIDA: Subir a GitHub (His-TECNM-MX)

## 📋 Pasos para Subir el Proyecto

### Opción 1: Usar el Script Automático (Recomendado) ⭐

```powershell
cd C:\Users\Ulises\Desktop\Hospital-FHIR-System
.\subir-a-github.ps1
```

El script te guiará paso a paso. Solo necesitas:
1. Tu nombre de usuario de GitHub
2. Crear el repositorio en GitHub cuando te lo pida

---

### Opción 2: Comandos Manuales

#### 1. Crear el repositorio en GitHub

Ve a: https://github.com/new

Configuración:
- **Repository name**: `His-TECNM-MX`
- **Description**: "Sistema Hospitalario - TECNM México con HAPI FHIR"
- **Visibility**: Public o Private
- ❌ **NO** marcar "Initialize this repository with a README"
- ❌ **NO** agregar .gitignore
- ❌ **NO** agregar licencia

Click en **Create repository**

#### 2. Conectar con GitHub

```powershell
cd C:\Users\Ulises\Desktop\Hospital-FHIR-System

# Agregar remote (reemplaza TU_USUARIO con tu username)
git remote add origin https://github.com/TU_USUARIO/His-TECNM-MX.git

# Asegurar que la rama sea 'main'
git branch -M main

# Subir el código
git push -u origin main
```

#### 3. Verificar

Ve a: `https://github.com/TU_USUARIO/His-TECNM-MX`

---

## 🔐 Autenticación

### Si GitHub pide credenciales:

**GitHub ya NO acepta contraseñas**. Necesitas un **Personal Access Token**:

1. Ve a: https://github.com/settings/tokens
2. Click en **Generate new token** → **Generate new token (classic)**
3. Configuración:
   - **Note**: "His-TECNM-MX Token"
   - **Expiration**: 90 days (o el que prefieras)
   - **Select scopes**: 
     - ✅ `repo` (Full control of private repositories)
4. Click en **Generate token**
5. **¡COPIA EL TOKEN!** (solo se muestra una vez)
6. Úsalo como contraseña cuando Git te lo pida

---

## 📊 Estado Actual del Proyecto

```
✅ Git inicializado
✅ .gitignore configurado
✅ Commit inicial creado (306 archivos)
✅ Listo para subir a GitHub
```

---

## 🎯 Después de Subir

### Configurar README Badges

Agrega al inicio del README.md:

```markdown
# His-TECNM-MX

[![Java](https://img.shields.io/badge/Java-21-orange.svg)](https://openjdk.org/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.9-green.svg)](https://spring.io/projects/spring-boot)
[![HAPI FHIR](https://img.shields.io/badge/HAPI%20FHIR-8.6.1-blue.svg)](https://hapifhir.io/)
[![Flutter](https://img.shields.io/badge/Flutter-3.27.3-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
```

### Configurar Branch Protection

1. Ve a: Settings → Branches
2. Add branch protection rule
3. Branch name pattern: `main`
4. Activar:
   - ✅ Require pull request reviews before merging
   - ✅ Require status checks to pass before merging

### Invitar Colaboradores

1. Ve a: Settings → Collaborators
2. Click en **Add people**
3. Busca y selecciona el colaborador
4. Asigna permisos (Write, Maintain, Admin)

---

## 🆘 Problemas Comunes

### Error: "remote origin already exists"
```powershell
git remote remove origin
git remote add origin https://github.com/TU_USUARIO/His-TECNM-MX.git
```

### Error: "failed to push some refs"
```powershell
# Si el repositorio remoto tiene commits que no tienes localmente
git pull origin main --rebase
git push -u origin main
```

### Error: "Authentication failed"
- Asegúrate de usar un **Personal Access Token** como contraseña
- NO uses tu contraseña de GitHub (ya no funciona)

---

## 📞 Contacto

Para dudas o problemas:
1. Consulta [REORGANIZACION_COMPLETADA.md](REORGANIZACION_COMPLETADA.md)
2. Revisa [README.md](README.md)
3. Consulta la documentación en `backend/` y `frontend/`

---

**Última actualización**: Marzo 11, 2026
