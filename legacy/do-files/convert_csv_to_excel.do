* --- --- --- --- --- --- --- --- --- 
* Convertir CSV a Excel al final
* --- --- --- --- --- --- --- --- --- 
* Este script se ejecuta DESPUÉS de generar los CSVs
* y los convierte a archivos Excel

* Definir paths
global path_work "/Users/jmunozm1/Documents/GitHub/household_structure_burundi/"
global path_results "$path_work/out"

* Lista de archivos CSV a convertir
local csv_files "results_welfare_all results_welfare_adult results_welfare_child results_welfare_woman results_welfare_man"

foreach file of local csv_files {
    di "Convirtiendo `file'.csv a Excel..."
    
    * Importar CSV
    import delimited "$path_results/`file'.csv", clear
    
    * Exportar a Excel
    export excel using "$path_results/`file'.xlsx", replace first(var)
    
    di "✓ `file'.xlsx creado exitosamente"
}

di ""
di "============================================"
di "Conversión completada"
di "Archivos Excel creados en: $path_results"
di "============================================"
