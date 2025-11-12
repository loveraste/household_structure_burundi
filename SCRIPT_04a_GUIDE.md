# Script 04a: Resultados Significativos - Guía de Uso

## Descripción

El script `04a_Welfare_Significant_Results_Akresh-etal_August2025.do` ejecuta todas las regresiones del script `04_Welfare_new_Akresh-etal_August2025.do` pero **guarda SOLO los resultados estadísticamente significativos** en un archivo Excel consolidado.

## ¿Por qué necesitas este script?

✅ **Reduce el ruido**: Elimina coeficientes no significativos  
✅ **Enfoque en hallazgos clave**: Solo muestra relaciones estadísticas importantes  
✅ **Tabla resumen compacta**: Un solo archivo Excel con todos los resultados significativos  
✅ **Trazabilidad**: Incluye información sobre qué interacción generó cada resultado  

## Estructura del Output

El script crea un archivo `significant_results.xlsx` con las siguientes columnas:

| Columna | Descripción |
|---------|-------------|
| `var_name` | Nombre de la variable/coeficiente |
| `estimate` | Valor del coeficiente estimado |
| `stderr` | Error estándar |
| `pvalue` | P-valor de la prueba t |
| `significant` | Nivel de significancia (\*, \*\*, \*\*\*) |
| `sample_type` | Tipo de muestra (General, Adult, Child, Woman, Man) |
| `interaction_var` | Variable de interacción utilizada |
| `n_obs` | Número de observaciones |
| `r2` | R-cuadrado del modelo |

## Niveles de Significancia

- `*` = p < 0.10 (significancia al 10%)
- `**` = p < 0.05 (significancia al 5%)
- `***` = p < 0.01 (significancia al 1%)

## Cómo ejecutar

### Opción 1: Desde terminal
```bash
/usr/local/bin/stata-se -b do "/Users/jmunozm1/Documents/GitHub/household_structure_burundi/do-files/04a_Welfare_Significant_Results_Akresh-etal_August2025.do"
```

### Opción 2: Desde VS Code
1. Abre el archivo `04a_Welfare_Significant_Results_Akresh-etal_August2025.do`
2. Presiona `Cmd + Shift + B` (si tienes tareas configuradas)
3. O usa la extensión STATA

### Opción 3: Ejecutar dentro de STATA
```stata
do "/Users/jmunozm1/Documents/GitHub/household_structure_burundi/do-files/04a_Welfare_Significant_Results_Akresh-etal_August2025.do"
```

## Proceso del Script

### Paso 1: Carga y Preparación de Datos
- Carga los datos preliminares
- Aplica las mismas transformaciones que el script 04
- Genera variables de migración, violencia, shocks y PCA

### Paso 2: Ejecución de Regresiones
- Ejecuta todas las combinaciones de:
  - **Base vars**: 48 variables de exposición/intensidad/shocks
  - **Interactions**: 3 variables de migración
  - **Samples**: 5 tipos (General, Adult, Child, Woman, Man)
  - **Total**: 48 × 3 × 5 = 720 regresiones

### Paso 3: Filtrado de Resultados
- Para cada coeficiente: extrae p-valor
- Si p < 0.10: guarda el resultado
- Descarta coeficientes no significativos

### Paso 4: Exportación
- Guarda resultados significativos en CSV
- Convierte a Excel (.xlsx)
- Crea resumen por tipo de muestra

## Archivos Generados

```
out/
├── significant_results.csv         # Versión CSV (backup)
├── significant_results.xlsx        # Versión Excel (final) ✨
└── significant_results_temp.dta    # Temporal (se elimina)
```

## Interpretación de Resultados

### Ejemplo de salida esperada:

```
Variable                          Estimate  Stderr  P-value  Sig  Sample Type      Interaction
---------------------------------------------------------------------------------------------------------
any_leave_adult#c.any_violence       -0.045   0.021   0.031   **   Adult Migration  any_leave_adult
years_violence#c.share_leave         -0.012   0.005   0.025   **   General          share_leave
avg_deathwounded_100#c.any_leave      0.003   0.001   0.008   **   General          any_leave
```

### Cómo leer:
- **any_leave_adult#c.any_violence**: El efecto de la interacción entre presencia de adultos que dejan el hogar y presencia de violencia
- **Estimate = -0.045**: Reduce la pobreza 2007 en 4.5 puntos porcentuales
- **Sig = \*\***: Significativo al 5%
- **Sample Type = Adult Migration**: Resultado en la submuestra de migración adulta

## Comparación con Script 04

| Aspecto | Script 04 | Script 04a |
|---------|-----------|-----------|
| **Output** | 5 archivos (todos los resultados) | 1 archivo (solo significativos) |
| **Filas Excel** | Miles | Cientos (típicamente) |
| **Enfoque** | Exhaustivo | Selectivo |
| **Uso** | Análisis completo | Presentación/Paper |
| **Tiempo ejecución** | ~5-10 min | ~5-10 min (igual) |

## Log de Ejecución

El script imprime al log:

```
==========================================
Resultados Significativos Encontrados: 124
==========================================
✓ Archivo guardado: significant_results.xlsx
  Filas: 124
  Columnas: variable, estimado, error estándar, p-value, significancia, tipo de muestra

========================================
Resumen de Resultados Significativos por Tipo de Muestra:
==========================================
  General (All): 34 (p<0.05), 52 (p<0.10)
  Adult Migration: 28 (p<0.05), 41 (p<0.10)
  Child Migration: 15 (p<0.05), 28 (p<0.10)
  Woman Migration: 8 (p<0.05), 15 (p<0.10)
  Man Migration: 5 (p<0.05), 12 (p<0.10)
```

## Opciones de Customización

Si quieres cambiar los umbrales de significancia, busca esta línea:

```stata
if `pval' < 0.10 {  // Cambiar a 0.05 para solo 5% significancia
```

Cambios comunes:
- **Solo p < 0.05**: reemplaza `0.10` con `0.05`
- **Solo p < 0.01**: reemplaza `0.10` con `0.01`

## Preguntas Frecuentes

### P: ¿Cuánto tiempo tarda?
R: Similar al script 04 (~5-10 minutos) porque ejecuta todas las regresiones. El filtrado es muy rápido.

### P: ¿Puedo combinar los resultados del script 04 y 04a?
R: Sí. El 04a es un subconjunto de 04. Usa 04a para presentaciones/paper y 04 para validación robustez.

### P: ¿Qué pasa si no hay resultados significativos?
R: El script muestra "⚠ No se encontraron resultados significativos" y no crea Excel.

### P: ¿Cómo cambio el nivel de significancia?
R: Modifica `if `pval' < 0.10` (línea ~280) al valor que prefieras.

### P: ¿Puedo ver todos los coeficientes incluso los no significativos?
R: Sí, usa el script 04 en lugar de 04a.

## Workflow Recomendado

1. **Primera corrida**: Ejecuta script `04a` para ver resultados clave
2. **Validación**: Ejecuta script `04` para la tabla completa
3. **Presentación**: Usa resultados de `04a`
4. **Robustez**: Consulta tabla completa de `04` para alternativas

## Integración con Otros Scripts

Este script puede encadenarse:

```stata
* En Master_Do-Files.do
do "do-files/04_Welfare_new_Akresh-etal_August2025.do"
do "do-files/04a_Welfare_Significant_Results_Akresh-etal_August2025.do"
```

Así obtendrás automáticamente:
- `results_welfare_all.xlsx`, `.adult`, `.child`, `.woman`, `.man`
- `significant_results.xlsx` (resumido)

## Archivos Generados en el Flujo Completo

```
out/
├── results_welfare_all.xlsx        # Completo (04)
├── results_welfare_adult.xlsx      # Completo (04)
├── results_welfare_child.xlsx      # Completo (04)
├── results_welfare_woman.xlsx      # Completo (04)
├── results_welfare_man.xlsx        # Completo (04)
└── significant_results.xlsx        # Solo significativos (04a) ← NUEVO
```

## Recomendaciones

✅ **Para papers**: Usa `significant_results.xlsx`  
✅ **Para apéndices**: Usa `results_welfare_all.xlsx`  
✅ **Para validación**: Compara ambos  
✅ **Para presentaciones**: Filtra manualmente del `significant_results.xlsx`

---

¿Necesitas ajustes al script o tienes dudas sobre la interpretación?
