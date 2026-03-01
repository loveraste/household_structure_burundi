# Solución: Exportar Resultados a Excel en STATA (macOS)

## Problema
En STATA para macOS, `esttab` tiene limitaciones al exportar directamente a archivos Excel (`.xlsx`). El comando falla con el error:
```
file /results_welfare_all.xlsx not found
file /results_welfare_all.xlsx could not be opened
```

## Solución Implementada

He implementado un flujo de dos pasos en tu script `04_Welfare_new_Akresh-etal_August2025.do`:

### 1️⃣ Paso 1: Exportar a CSV
Los resultados de regresión se exportan primero a archivos **CSV** (formato compatible):
```stata
esttab m* using "$path_results/results_welfare_all.csv", replace ...
```

**Por qué CSV?**
- ✅ Totalmente compatible con STATA en macOS
- ✅ Conserva toda la información de las tablas
- ✅ Se puede abrir en Excel

### 2️⃣ Paso 2: Convertir CSV a Excel (AUTOMÁTICO)
Al final del script, se ejecuta automáticamente:

```stata
foreach file of local csv_files {
    import delimited "$path_results/`file'.csv", clear
    export excel using "$path_results/`file'.xlsx", replace first(var)
}
```

Este código:
1. Lee el archivo CSV
2. Lo convierte a Excel usando `export excel` (comando nativo de STATA)
3. Crea un archivo `.xlsx` con la primera fila como encabezado

## Archivos Generados

Cuando ejecutes el script, obtendrás **10 archivos** en `$path_results/out/`:

### Versión CSV (intermedios)
- `results_welfare_all.csv`
- `results_welfare_adult.csv`
- `results_welfare_child.csv`
- `results_welfare_woman.csv`
- `results_welfare_man.csv`

### Versión Excel (finales) ✨
- `results_welfare_all.xlsx`
- `results_welfare_adult.xlsx`
- `results_welfare_child.xlsx`
- `results_welfare_woman.xlsx`
- `results_welfare_man.xlsx`

## Cómo Ejecutar

### Opción 1: Ejecutar todo el script
```bash
/usr/local/bin/stata-se -b do "/Users/jmunozm1/Documents/GitHub/household_structure_burundi/do-files/04_Welfare_new_Akresh-etal_August2025.do"
```

### Opción 2: Desde VS Code
1. Abre el archivo `.do`
2. Presiona `Cmd + Shift + B` (si tienes tareas configuradas)
3. O usa la extensión STATA

### Opción 3: Solo convertir CSVs existentes
Si ya tienes los CSVs y solo quieres convertirlos:
```bash
/usr/local/bin/stata-se -b do "/Users/jmunozm1/Documents/GitHub/household_structure_burundi/do-files/convert_csv_to_excel.do"
```

## Verificación

Para verificar que todo funcionó correctamente:

```bash
# Ver los archivos creados
ls -lh ~/Documents/GitHub/household_structure_burundi/out/results_welfare_*.xlsx

# Verificar que son Excel válidos
file ~/Documents/GitHub/household_structure_burundi/out/results_welfare_*.xlsx
```

Deberías ver algo como:
```
results_welfare_all.xlsx: Microsoft Excel 2007+
results_welfare_adult.xlsx: Microsoft Excel 2007+
```

## Ventajas de esta Solución

✅ **Compatible**: Funciona perfectamente en macOS  
✅ **Automática**: No requiere pasos manuales  
✅ **Transparente**: El usuario ve solo los archivos finales (.xlsx)  
✅ **Fiable**: Usa comandos nativos de STATA  
✅ **Flexible**: Los CSVs se guardan como backup  

## Si tienes problemas

### Problema: "Error procesando results_welfare_all"
**Solución**: Verifica que los CSVs se crearon correctamente
```stata
ls "$path_results/*.csv"
```

### Problema: Los Excel no tienen datos
**Solución**: Verifica que `first(var)` está en la exportación
```stata
export excel using "test.xlsx", replace first(var)
```

### Problema: Rutas no encontradas
**Solución**: Verifica que `path_results` está definido
```stata
di "$path_results"  // Debe mostrar la ruta correcta
```

## Scripts Auxiliares Creados

1. **`convert_csv_to_excel.do`**: Script independiente para convertir CSVs a Excel
2. **`utils_excel_export.do`**: Utilidades para futuras exportaciones

## Próximos Pasos

Si quieres mejorar aún más el formato:

1. **Agregar colores a los encabezados**:
   ```stata
   local row = 1
   foreach var of varlist * {
       putexcel A`row' = "`var'", fmtID(bold_fill)
       local row = `row' + 1
   }
   ```

2. **Crear múltiples hojas** en un solo Excel:
   ```stata
   foreach file of local csv_files {
       import delimited "$path_results/`file'.csv", clear
       export excel using "$path_results/results_consolidated.xlsx", ///
           sheet("`file'") sheetreplace
   }
   ```

3. **Agregar estadísticas resumidas** al inicio de cada hoja

¿Necesitas ayuda implementando alguna de estas mejoras?
