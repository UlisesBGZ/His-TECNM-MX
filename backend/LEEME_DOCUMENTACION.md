# 📚 Índice de Documentación del Proyecto

## 🚀 ¿Qué es este README?

Este es el índice de toda la documentación disponible para transferir el proyecto a una nueva laptop o continuar el desarrollo.

---

## 📄 Guías Disponibles

### 🌟 Para Transferir a Nueva Laptop

| Archivo | Propósito | Cuándo Usar |
|---------|-----------|-------------|
| **[GUIA_GITHUB.md](GUIA_GITHUB.md)** | ⭐ **RECOMENDADO**: Subir y clonar desde GitHub | Mejor método, más confiable |
| **[subir-a-github.ps1](subir-a-github.ps1)** | Script automático para subir a GitHub | Ejecutar con `.\subir-a-github.ps1` |
| **[CHECKLIST_TRANSFERENCIA.md](CHECKLIST_TRANSFERENCIA.md)** | Checklist paso a paso para transferir | Verificar que no falte nada |
| **[GUIA_TRANSFERIR_VSCODE.md](GUIA_TRANSFERIR_VSCODE.md)** | Configurar VS Code en nueva laptop | Extensiones, snippets, tareas |

### 📖 Para Entender el Proyecto

| Archivo | Propósito | Contenido |
|---------|-----------|-----------|
| **[CONTEXTO_PARA_NUEVA_SESION.md](CONTEXTO_PARA_NUEVA_SESION.md)** | Contexto técnico completo (5,500 líneas) | Estructura, configuración, endpoints, comandos |
| **[DESARROLLO_COMPLETO.md](DESARROLLO_COMPLETO.md)** | Historia del desarrollo (700+ líneas) | Problemas resueltos, decisiones técnicas |
| **[PROMPT_PARA_NUEVA_IA.md](PROMPT_PARA_NUEVA_IA.md)** | Prompt para nueva sesión de IA | Copiar/pegar en Copilot Chat |
| **[.github/copilot-instructions.md](.github/copilot-instructions.md)** | Instrucciones para GitHub Copilot | Se lee automáticamente en VS Code |

### 🔧 Scripts Útiles

| Archivo | Propósito | Comando |
|---------|-----------|---------|
| `subir-a-github.ps1` | Subir proyecto a GitHub automáticamente | `.\subir-a-github.ps1` |
| `flutter_frontend/update-ip.ps1` | Actualizar IP de red para móvil | `cd flutter_frontend; .\update-ip.ps1` |

---

## 🎯 Flujo Recomendado

### Si Vas a Transferir el Proyecto:

```
1. 📖 Leer: GUIA_GITHUB.md (5 min)
2. 🚀 Ejecutar: .\subir-a-github.ps1 (5-10 min)
3. 💻 En nueva laptop: git clone + seguir CHECKLIST_TRANSFERENCIA.md (15-20 min)
4. 🤖 Configurar VS Code: seguir GUIA_TRANSFERIR_VSCODE.md (10 min)
```

**Tiempo total**: ~35-45 minutos

---

### Si Vas a Continuar Desarrollo con IA:

```
1. 📖 Abrir: PROMPT_PARA_NUEVA_IA.md
2. 📋 Copiar todo el contenido (Ctrl+A, Ctrl+C)
3. 💬 Abrir Copilot Chat en VS Code (Ctrl+Shift+I)
4. 📝 Pegar y agregar tu petición
```

**Tiempo total**: ~2 minutos

---

## 📊 Estado Actual del Proyecto

**✅ COMPLETAMENTE FUNCIONAL**

- **Backend**: Spring Boot 3.5.9 + HAPI FHIR 8.6.1 + Java 21.0.10 en puerto 8080
- **Frontend**: Flutter 3.27.3 (web + Android)
- **Base de Datos**: PostgreSQL 16 en Docker (puerto 5432)
- **Build**: Maven Wrapper 3.3.2 (incluido en repo, NO requiere instalación)
- **Tests**: 23/23 backend ✅ + 25/25 frontend ✅ (100% pasando)
- **Configuración**: Dinámica (localhost para web, IP 192.168.0.181 para móvil)

---

## 🔐 Credenciales de Desarrollo

**Usuario Admin**:
- Username: `admin`
- Password: `admin123`

**Base de Datos**:
- Host: `localhost:5432`
- Database: `fhirdb`
- User: `admin`
- Password: `admin`

⚠️ **Cambiar en producción** (ver documentación)

---

## 🚀 Comandos Rápidos

```powershell
# Backend
.\mvnw.cmd spring-boot:run -Pboot

# Frontend Web
cd flutter_frontend; flutter run -d chrome

# Tests Backend
.\mvnw.cmd test -Dtest="AuthControllerTest,UserControllerTest"

# Tests Frontend
cd flutter_frontend; flutter test

# Docker (Base de Datos)
docker-compose up -d

# Actualizar IP (móvil)
cd flutter_frontend; .\update-ip.ps1
```

---

## 🔗 Enlaces Útiles

**Documentación Externa**:
- [HAPI FHIR Docs](https://hapifhir.io/hapi-fhir/docs/)
- [Spring Boot Reference](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [Flutter Documentation](https://docs.flutter.dev/)

**Proyecto**:
- GitHub: [Configurar según GUIA_GITHUB.md]
- Estado: ✅ Producción-ready para desarrollo local

---

## 🆘 ¿Necesitas Ayuda?

1. **Setup en nueva laptop**: Ver [CHECKLIST_TRANSFERENCIA.md](CHECKLIST_TRANSFERENCIA.md)
2. **Problemas técnicos**: Ver [DESARROLLO_COMPLETO.md](DESARROLLO_COMPLETO.md) sección "Solución de Problemas"
3. **Comandos específicos**: Ver [CONTEXTO_PARA_NUEVA_SESION.md](CONTEXTO_PARA_NUEVA_SESION.md)
4. **Configurar GitHub**: Ver [GUIA_GITHUB.md](GUIA_GITHUB.md)
5. **Configurar VS Code**: Ver [GUIA_TRANSFERIR_VSCODE.md](GUIA_TRANSFERIR_VSCODE.md)

---

## 📝 Notas Importantes

### Archivos Críticos que NO Deben Faltar:
- ✅ `.mvn/wrapper/maven-wrapper.jar` (61.5 KB)
- ✅ `mvnw.cmd`
- ✅ `flutter_frontend/update-ip.ps1`
- ✅ Toda esta documentación (.md)

### Archivos que NO Subir a GitHub:
- ❌ `target/` (compilados)
- ❌ `flutter_frontend/build/` (compilados)
- ❌ `mvnw.cmd.backup` (backup corrupto)
- ❌ `.env` (si lo creas)

**(Ya configurado en .gitignore)**

---

## 🎊 Resumen

Este proyecto incluye:

1. ✅ **Sistema funcional** (backend + frontend + BD)
2. ✅ **Tests completos** (48 tests pasando)
3. ✅ **Documentación exhaustiva** (8 archivos .md)
4. ✅ **Scripts de automatización** (subir-a-github.ps1, update-ip.ps1)
5. ✅ **Configuración para IA** (Copilot, prompts listos)
6. ✅ **Guías de transferencia** (GitHub, VS Code, Checklist)

**¡Todo listo para transferir y continuar desarrollo!** 🚀

---

*Última actualización: 21 de Febrero, 2026*  
*Versión: 1.0*
