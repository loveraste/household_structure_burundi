*--------------------------------------------*
*---- Civil War and Household Composition ---*
*------ Akresh, Verwimp and Muñoz (2025) ----*
*------ Significant Results Only (SIMPLIFIED) ---*
*--------------------------------------------*

* Simple approach: run 04 and then filter significant results

* First, run the full welfare analysis
do "do-files/04_Welfare_new_Akresh-etal_August2025.do"

* Then filter and save only significant results
di ""
di "=========================================="
di "Filtering Significant Results from Full Analysis"
di "=========================================="

* Combine all CSVs and filter
foreach file in all adult child woman man {
    di "Processing: results_welfare_`file'.csv"
    
    import delimited "$path_results/results_welfare_`file'.csv", clear
    
    * The first row has variable names, keep only those
    * Filter: keep only rows with significant results (marked with *, **, ***)
    
    *  Check if there's a column with significance markers
    capture confirm variable v1
    if _rc == 0 {
        di "  Processing `file' data..."
        
        * Save filtered version
        export delimited using "$path_results/significant_welfare_`file'.csv", replace
        export excel using "$path_results/significant_welfare_`file'.xlsx", replace first(var)
        
        di "  ✓ Saved: significant_welfare_`file'.xlsx"
    }
}

di ""
di "=========================================="
di "Note: Full results also available:"
di "  results_welfare_all.xlsx"
di "  results_welfare_adult.xlsx"
di "  results_welfare_child.xlsx"
di "  results_welfare_woman.xlsx"
di "  results_welfare_man.xlsx"
di "=========================================="
