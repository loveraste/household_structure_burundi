# Configuración de STATA en VS Code

## Paso 1: Extensión Recomendada

Instala la extensión oficial de STATA para VS Code:
- **Extension Name**: Stata Editing Support
- **Extension ID**: seanmcilmoyle.code-stata
- **Publisher**: Sean McIlmoyle

O desde la terminal:
```bash
code --install-extension seanmcilmoyle.code-stata
```

## Paso 2: Configurar la Ruta de STATA

Abre VS Code y accede a **Preferences > Settings** (o presiona `Cmd + ,`)

Busca "stata" y configura:

### Opción A: Mediante Interfaz de Configuración
1. Busca `stata.executionMode`
2. Selecciona según tu preferencia:
   - **"do"**: Ejecuta a través de archivos `.do`
   - **"batch"**: Modo batch (recomendado para scripts)

3. Busca `stata.stataPath` y establece:
```
/usr/local/bin/stata-se
```

### Opción B: Editar settings.json directamente
Presiona `Cmd + Shift + P` y escribe "Preferences: Open User Settings (JSON)"

Agrega o modifica:
```json
{
    "stata.stataPath": "/usr/local/bin/stata-se",
    "stata.executionMode": "batch",
    "stata.doFileDir": "${workspaceFolder}",
    "stata.arguments": "-b do"
}
```

## Paso 3: Configuración Avanzada (settings.json)

Aquí está la configuración recomendada para tu proyecto:

```json
{
    "[stata]": {
        "editor.defaultFormatter": "seanmcilmoyle.code-stata"
    },
    "stata.stataPath": "/usr/local/bin/stata-se",
    "stata.executionMode": "do",
    "stata.doFileDir": "${workspaceFolder}/do-files",
    "stata.arguments": "",
    "editor.formatOnSave": true,
    "editor.rulers": [80, 120],
    "editor.wordWrap": "on"
}
```

## Paso 4: Crear Tareas en VS Code (tasks.json)

Crea un archivo `.vscode/tasks.json` en tu proyecto:

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Run STATA (Batch Mode)",
            "type": "shell",
            "command": "/usr/local/bin/stata-se",
            "args": [
                "-b",
                "do",
                "${file}"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            },
            "presentation": {
                "echo": true,
                "reveal": "always",
                "panel": "shared"
            },
            "problemMatcher": []
        },
        {
            "label": "Run STATA Master File",
            "type": "shell",
            "command": "/usr/local/bin/stata-se",
            "args": [
                "-b",
                "do",
                "${workspaceFolder}/do-files/Master_Do-Files.do"
            ],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "panel": "new"
            }
        }
    ]
}
```

## Paso 5: Configurar Keybindings (Atajos de Teclado)

Opcionalmente, agrega atajos personalizados. Presiona `Cmd + K Cmd + S` o ve a **Preferences > Keyboard Shortcuts**.

Busca "stata" en los comandos disponibles:
- `stata.runCode`: Ejecuta el código seleccionado
- `stata.runFile`: Ejecuta el archivo actual
- `stata.runSelection`: Ejecuta la selección

Puedes agregar en `keybindings.json`:
```json
{
    "key": "cmd+shift+r",
    "command": "stata.runFile",
    "when": "editorLangId == stata"
},
{
    "key": "cmd+enter",
    "command": "stata.runCode",
    "when": "editorLangId == stata"
}
```

## Paso 6: Ejecutar STATA desde VS Code

### Opción 1: Usar la Extensión Directamente
1. Abre un archivo `.do` en VS Code
2. Presiona los atajos de teclado configurados o usa la paleta de comandos (`Cmd + Shift + P`)
3. Escribe "STATA: Run" o "STATA: Run File"

### Opción 2: Usar las Tareas
1. Presiona `Cmd + Shift + B` o ve a **Terminal > Run Task**
2. Selecciona:
   - "Run STATA (Batch Mode)" - para ejecutar el archivo actual
   - "Run STATA Master File" - para ejecutar el Master file

### Opción 3: Desde Terminal
```bash
# Ejecutar un archivo do individual
/usr/local/bin/stata-se -b do /Users/jmunozm1/Documents/GitHub/household_structure_burundi/do-files/Master_Do-Files.do

# Ejecutar en modo interactivo
/usr/local/bin/stata-se
```

## Paso 7: Ver Logs de STATA

STATA generará archivos `.log` en la misma carpeta que tu archivo `.do`.

Crea un script para visualizar los logs automáticamente:

```json
{
    "label": "View STATA Log",
    "type": "shell",
    "command": "cat",
    "args": ["${fileDirname}/${fileBasenameNoExtension}.log"],
    "presentation": {
        "reveal": "always",
        "panel": "new"
    }
}
```

## Configuración Recomendada para tu Proyecto

Crea `.vscode/settings.json` específico para este proyecto:

```json
{
    "stata.stataPath": "/usr/local/bin/stata-se",
    "stata.executionMode": "do",
    "stata.doFileDir": "${workspaceFolder}/do-files",
    "files.exclude": {
        "**/*.log": false
    },
    "files.associations": {
        "*.do": "stata"
    },
    "[stata]": {
        "editor.tabSize": 4,
        "editor.insertSpaces": true,
        "editor.formatOnSave": true
    }
}
```

## Solución de Problemas

### Problema: "STATA no encontrado"
**Solución**: Verifica la ruta exacta:
```bash
ls -la /usr/local/bin/stata-se
# Debería mostrar algo como:
# stata-se -> /Applications/StataNow/StataSE.app/Contents/MacOS/stata-se
```

### Problema: Permiso denegado
**Solución**:
```bash
chmod +x /usr/local/bin/stata-se
```

### Problema: El archivo .log no se crea
**Solución**: Asegúrate que:
1. Tienes permisos de escritura en la carpeta de destino
2. El archivo `.do` tiene la ruta correcta definida en `path_work`
3. Ejecuta con `-b` (batch mode) para generar logs automáticos

### Problema: No reconoce variables globales
**Solución**: En tus scripts `.do`, asegúrate de:
1. Definir `global path_work` antes de usarlo
2. Verificar las rutas relativas en `Master_Do-Files.do`

Ejemplo:
```stata
global path_work "/Users/jmunozm1/Documents/GitHub/household_structure_burundi"
cd "$path_work"
```

## Verificación de la Instalación

Ejecuta este comando para verificar que todo está configurado:

```bash
# Verificar STATA
/usr/local/bin/stata-se --version

# O crear un test simple
echo 'clear all' > /tmp/test.do
echo 'display "STATA works!"' >> /tmp/test.do
/usr/local/bin/stata-se -b do /tmp/test.do
cat /tmp/test.log
```

## Próximos Pasos

1. ✅ Instala la extensión STATA
2. ✅ Configura `settings.json`
3. ✅ Crea `.vscode/tasks.json`
4. ✅ Prueba ejecutando un archivo `.do` simple
5. ✅ Ajusta según necesidades

## Referencias

- [Stata Editing Support - VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=seanmcilmoyle.code-stata)
- [STATA Documentation](https://www.stata.com/manuals/u1.pdf)
- [VS Code Tasks Documentation](https://code.visualstudio.com/docs/editor/tasks)
