# 🔄 Guía: Transferir Sesión a Nuevo VS Code

## ✅ Ya lo Tienes Todo Listo

He creado estos archivos para transferir tu sesión:

1. **PROMPT_PARA_NUEVA_IA.md** - Prompt completo para nueva sesión de IA
2. **CONTEXTO_PARA_NUEVA_SESION.md** - Documentación técnica completa
3. **CHECKLIST_TRANSFERENCIA.md** - Pasos de setup
4. **.github/copilot-instructions.md** - Instrucciones para GitHub Copilot

---

## 🚀 Método Rápido (5 minutos)

### Opción A: Transferir con GitHub (RECOMENDADO) 🌟

**Ventajas**: Más confiable, tienes respaldo, control de versiones

#### **En tu Laptop Actual:**
```powershell
# Ejecutar script automático
.\subir-a-github.ps1

# O seguir la guía completa:
# Ver: GUIA_GITHUB.md
```

#### **En tu Nueva Laptop:**
```powershell
# Clonar desde GitHub
cd C:\Users\<TU_USUARIO>\Desktop
git clone https://github.com/TU_USUARIO/hapi-fhir-hospital-system.git
cd hapi-fhir-hospital-system

# Abrir en VS Code
code .
```

---

### Opción B: Transferir Copiando Archivos

#### **Paso 1: Abrir proyecto en VS Code**
```powershell
cd C:\Users\<TU_USUARIO>\Desktop\hapi-fhir-jpaserver-starter
code .
```

#### **Paso 2: Usar el Prompt Preparado**

**Opción A: Con GitHub Copilot Chat**
1. Presiona `Ctrl + Shift + I` para abrir Copilot Chat
2. Abre el archivo `PROMPT_PARA_NUEVA_IA.md`
3. Selecciona todo (`Ctrl + A`) y copia (`Ctrl + C`)
4. Pega en el chat de Copilot
5. Agrega tu petición al final:
   ```
   [PROMPT COMPLETO PEGADO]
   
   ---
   
   ## 💬 PETICIÓN ACTUAL
   
   Ayúdame a verificar que todo está funcionando correctamente.
   ```
6. Envía el mensaje

**Opción B: Copilot leerá automáticamente el contexto**
- GitHub Copilot puede leer `.github/copilot-instructions.md` automáticamente
- Simplemente empieza a hacer preguntas normalmente
- Copilot tendrá el contexto del proyecto

**Opción C: Con @workspace**
```
@workspace ¿Cuál es la estructura del sistema de autenticación?
```
Copilot leerá los archivos del workspace para responder.

---

## 📖 Métodos de Referencia

### **1. Referencia Rápida en Chat**

Cuando hagas una pregunta, puedes mencionar archivos específicos:

```
@CONTEXTO_PARA_NUEVA_SESION.md ¿Cómo ejecuto los tests del backend?
```

### **2. Usar Snippets de Comandos**

Crea atajos para comandos comunes:

**settings.json** en VS Code:
```json
{
  "terminal.integrated.profiles.windows": {
    "PowerShell": {
      "source": "PowerShell",
      "icon": "terminal-powershell"
    }
  },
  "terminal.integrated.defaultProfile.windows": "PowerShell"
}
```

**Comandos frecuentes** (crea archivo `COMANDOS_RAPIDOS.md`):
```markdown
# Backend
.\mvnw.cmd spring-boot:run -Pboot

# Frontend
cd flutter_frontend; flutter run -d chrome

# Tests
.\mvnw.cmd test -Dtest="Auth*,User*"

# Actualizar IP
cd flutter_frontend; .\update-ip.ps1

# Docker
docker-compose up -d
```

### **3. Extensiones Útiles de VS Code**

Instala estas extensiones en tu nuevo VS Code:

```powershell
# En VS Code, presiona Ctrl+P y ejecuta cada línea:
ext install vscjava.vscode-spring-boot-dashboard
ext install vscjava.vscode-spring-initializr
ext install vscjava.vscode-maven
ext install Dart-Code.flutter
ext install Dart-Code.dart-code
ext install ms-azuretools.vscode-docker
ext install GitHub.copilot
ext install GitHub.copilot-chat
```

---

## 🎯 Escenarios Comunes

### **Escenario 1: Nuevo Desarrollo**

```
[En Copilot Chat]

Contexto: Estoy trabajando en el proyecto HAPI FHIR con autenticación JWT. 
Revisa .github/copilot-instructions.md para conocer la estructura.

Tarea: Necesito agregar un endpoint para cambiar contraseña de usuario.
¿Puedes ayudarme?
```

### **Escenario 2: Debugging**

```
[En Copilot Chat]

@CONTEXTO_PARA_NUEVA_SESION.md 

El backend no inicia. ¿Qué debo verificar?
```

### **Escenario 3: Consulta de Configuración**

```
[En Copilot Chat]

¿Cuál es la configuración actual de la base de datos según docker-compose.yml?
```

### **Escenario 4: Ejecutar Tests**

```
[En Copilot Chat]

@CONTEXTO_PARA_NUEVA_SESION.md 

¿Cuál es el comando para ejecutar solo los tests de autenticación?
```

---

## 🔧 Tips para VS Code en Nueva Laptop

### **1. Configurar Terminal Integrada**

Abre Settings (`Ctrl + ,`) y busca "terminal default profile":
- Selecciona "PowerShell" como predeterminado

### **2. Multi-Root Workspace (Opcional)**

Si quieres tener frontend y backend separados:

Archivo: `hapi-fhir.code-workspace`
```json
{
  "folders": [
    {
      "name": "Backend",
      "path": "."
    },
    {
      "name": "Flutter Frontend",
      "path": "flutter_frontend"
    }
  ],
  "settings": {
    "java.configuration.updateBuildConfiguration": "automatic",
    "dart.flutterSdkPath": "C:\\src\\flutter"
  }
}
```

### **3. Tareas Automatizadas**

Crea `.vscode/tasks.json`:
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Iniciar Backend",
      "type": "shell",
      "command": ".\\mvnw.cmd spring-boot:run -Pboot",
      "group": "build",
      "problemMatcher": []
    },
    {
      "label": "Iniciar Frontend Web",
      "type": "shell",
      "command": "cd flutter_frontend && flutter run -d chrome",
      "group": "build",
      "problemMatcher": []
    },
    {
      "label": "Ejecutar Tests Backend",
      "type": "shell",
      "command": ".\\mvnw.cmd test -Dtest=\"AuthControllerTest,UserControllerTest\"",
      "group": "test",
      "problemMatcher": []
    },
    {
      "label": "Actualizar IP",
      "type": "shell",
      "command": "cd flutter_frontend && .\\update-ip.ps1",
      "problemMatcher": []
    }
  ]
}
```

**Usar tareas**: `Ctrl + Shift + P` → "Tasks: Run Task" → Seleccionar tarea

### **4. Snippets Personalizados**

Crea `.vscode/snippets.code-snippets`:
```json
{
  "Spring Controller Method": {
    "prefix": "springcontroller",
    "body": [
      "@PostMapping(\"/${1:endpoint}\")",
      "public ResponseEntity<?> ${2:methodName}(@RequestBody ${3:RequestDto} request, HttpServletRequest httpRequest) {",
      "    try {",
      "        // TODO: Implementar lógica",
      "        return ResponseEntity.ok(Map.of(\"message\", \"Success\"));",
      "    } catch (Exception e) {",
      "        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)",
      "            .body(Map.of(\"error\", e.getMessage()));",
      "    }",
      "}"
    ]
  },
  "Flutter Screen": {
    "prefix": "flutterscreen",
    "body": [
      "class ${1:ScreenName} extends StatefulWidget {",
      "  const ${1:ScreenName}({Key? key}) : super(key: key);",
      "",
      "  @override",
      "  State<${1:ScreenName}> createState() => _${1:ScreenName}State();",
      "}",
      "",
      "class _${1:ScreenName}State extends State<${1:ScreenName}> {",
      "  @override",
      "  Widget build(BuildContext context) {",
      "    return Scaffold(",
      "      appBar: AppBar(title: const Text('${2:Title}')),",
      "      body: ${3:Container}(),",
      "    );",
      "  }",
      "}"
    ]
  }
}
```

---

## 📱 Atajos de Teclado Útiles

| Acción | Atajo |
|--------|-------|
| **Copilot Chat** | `Ctrl + Shift + I` |
| **Command Palette** | `Ctrl + Shift + P` |
| **Quick File Open** | `Ctrl + P` |
| **Terminal Integrada** | `Ctrl + ñ` o `Ctrl + '` |
| **Buscar en Archivos** | `Ctrl + Shift + F` |
| **Ir a Definición** | `F12` |
| **Formato Código** | `Shift + Alt + F` |
| **Múltiples Cursores** | `Alt + Click` |
| **Comentar Línea** | `Ctrl + /` |

---

## 🎓 Mejores Prácticas

### **Al Hacer Preguntas a Copilot:**

**✅ BUENO:**
```
Necesito agregar un endpoint PUT /api/users/{id}/update-password en UserController.
Debe validar que el usuario esté autenticado, verificar contraseña actual con BCrypt,
y actualizar con nueva contraseña hasheada. ¿Puedes implementarlo siguiendo el patrón
de los endpoints existentes?
```

**❌ MALO:**
```
necesito cambiar password
```

### **Usar Referencias:**

**✅ BUENO:**
```
@AuthController.java 
Quiero crear un endpoint similar a login() pero para renovar el token JWT.
```

**❌ MALO:**
```
como hago para renovar tokens?
```

### **Contexto Incremental:**

**Primera pregunta:**
```
@workspace ¿Cuál es la estructura del sistema de autenticación?
```

**Siguientes preguntas:**
```
Según lo anterior, ¿cómo puedo agregar autenticación de dos factores?
```

---

## 🔄 Sincronizar entre Laptops

Si vas a trabajar entre dos laptops:

### **Opción 1: Git (Recomendado)**

```powershell
# Primera laptop
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/tuusuario/hapi-fhir-project.git
git push -u origin main

# Segunda laptop
git clone https://github.com/tuusuario/hapi-fhir-project.git
cd hapi-fhir-project
.\flutter_frontend\update-ip.ps1
```

### **Opción 2: VS Code Settings Sync**

1. En VS Code: `Ctrl + Shift + P`
2. "Settings Sync: Turn On"
3. Login con GitHub
4. Selecciona qué sincronizar:
   - ✅ Settings
   - ✅ Extensions
   - ✅ Keybindings
   - ✅ Snippets

### **Opción 3: OneDrive/Google Drive**

Coloca el proyecto en carpeta sincronizada:
```
C:\Users\<TU_USUARIO>\OneDrive\Proyectos\hapi-fhir-jpaserver-starter\
```

**Importante**: Excluir de sincronización:
- `target/`
- `flutter_frontend/build/`
- `.dart_tool/`
- `node_modules/` (si usas npm)

---

## ✅ Verificación Final

Después de configurar VS Code en la nueva laptop:

```powershell
# 1. Verificar que el proyecto se ve correcto
Get-ChildItem -Path . -Recurse -File | Measure-Object | Select-Object Count
# Debe mostrar varios miles de archivos

# 2. Probar Copilot
# En VS Code, abre cualquier archivo .java y escribe un comentario:
# // crear método para buscar usuario por email
# Copilot debería sugerir implementación

# 3. Verificar extensiones
code --list-extensions
# Debe incluir: GitHub.copilot, vscjava.vscode-spring-boot-dashboard, Dart-Code.flutter

# 4. Probar tareas
# Ctrl+Shift+P → "Tasks: Run Task" → Ver si aparecen las tareas definidas

# 5. Probar terminal integrada
# Ctrl+ñ → Debe abrir PowerShell
```

---

## 🆘 Si Copilot No Tiene Contexto

Si Copilot parece no saber del proyecto:

1. **Recarga VS Code**: `Ctrl + Shift + P` → "Developer: Reload Window"

2. **Usa el prompt manualmente**: Copia contenido de `PROMPT_PARA_NUEVA_IA.md` en el chat

3. **Referencias explícitas**: Usa `@archivo.md` en tus preguntas

4. **Verifica que `.github/copilot-instructions.md` existe**:
   ```powershell
   Test-Path .\.github\copilot-instructions.md
   # Debe retornar True
   ```

5. **Fuerza lectura del workspace**:
   ```
   @workspace dame un resumen completo del proyecto
   ```

---

## 🎊 ¡Listo!

Tu VS Code en la nueva laptop está listo cuando:

- ✅ Proyecto abierto en VS Code
- ✅ GitHub Copilot instalado y funcionando
- ✅ Extensiones Java y Flutter instaladas
- ✅ Terminal integrada configurada
- ✅ Archivo `.github/copilot-instructions.md` presente
- ✅ Puedes hacer preguntas a Copilot y obtiene contexto correcto

**Tiempo estimado de setup**: 10-15 minutos

---

**Próximo paso**: Abre Copilot Chat (`Ctrl + Shift + I`) y pregunta:
```
@workspace dame un resumen del proyecto y confirma que tienes el contexto completo
```

Si Copilot responde con detalles del sistema de autenticación JWT, HAPI FHIR, y Flutter, ¡todo está listo! 🚀
