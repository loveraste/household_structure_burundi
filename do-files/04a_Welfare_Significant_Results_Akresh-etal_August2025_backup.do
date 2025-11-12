*--------------------------------------------*
*---- Civil War and Household Composition ---*
*------ Akresh, Verwimp and Muñoz (2025) ----*
*------ Significant Results Only -----*
*--------------------------------------------*

* --- --- --- --- --- --- --- --- --- 
* We include the data preliminaries 
* --- --- --- --- --- --- --- --- --- 
  
	run "do-files/00_DataPreliminaries_Akresh-etal_2025.do"
	
* --- --- --- --- --- --- --- --- --- 
*  Sample 
* --- --- --- --- --- --- --- --- --- 

	* Only Parental household
		keep if numsplit==0
		drop if age==.
		drop age
		gen age=year-born_year_07
		* Registered household members
		drop if Code98==.

* --- --- --- --- --- --- --- --- --- 
* Set of Variables
* --- --- --- --- --- --- --- --- --- 

		global exposure "d_violence"
		global intensity "deathwounded_100"
		global tables_hh d_violence deathwounded_100 sk_vl_rob_land sk_vl_rob_product sk_vl_rob_money sk_vl_rob_goods sk_vl_rob_destruction pca_agri pca_asset pca_all
		
*************************************
*** Baseline Sample
*** NON-MARRIAGE MIGRATION 
************************************* 
		
		keep if restr_7==1
		variables
		qui include "$path_work/do-files/labels.do" 

		* Gen Province time trend
		xtset id_person year
		bys province year: gen province_trend=_n

		merge m:1 id_hh year using "$path_work/data/job/pca.dta", nogen
	
* --- Prepare data as in 04_Welfare ---

		rename year jaar
		merge m:1 reczd numen numsplit pid07 jaar using "$path_work/data/origin/demofinal17.dta", keepusing(totexp_a98 TOTEXP_mae07 litm98) keep(1 3) nogen
		rename jaar year
		
		replace leave = 0 if missing(leave)
		
		* Age
		gen leave_adult  = (leave == 1 & adult_18 == 1) 
		gen leave_child = (leave == 1 & adult_18 == 0) 
		* Sex
		gen leave_woman = (leave == 1 & sex == 1) 
		gen leave_man = (leave == 1 & sex == 0) 

		local migration leave leave_adult leave_child leave_woman leave_man

		* Tamaño del hogar
		bys id_hh year: gen hh_size = _N

		egen woman_size = total(sex==1), by(id_hh year)
		egen man_size = total(sex==0), by(id_hh year)
		egen child_size = total(adult_18==0), by(id_hh year)
		egen adult_size = total(adult_18==1), by(id_hh year)
		bys id_hh: egen max_child_size = max(child_size)
		bys id_hh: egen max_adult_size = max(adult_size)

		foreach v of local migration {
			bys id_hh: egen any_`v' = max(`v')
			sort id_person year
			gen first_`v' = 0
			by id_person (year): replace first_`v' = `v'==1 & (`v'[_n-1]==0 | _n==1)
			bys id_hh year: egen total_`v'_year = total(first_`v')
			bys id_hh: egen total_`v' = total(first_`v')
			gen share_`v' = .
			if      inlist("`v'","leave")                    replace share_`v' = total_`v'/hh_size
			else if inlist("`v'","leave_adult","mig_adult")  replace share_`v' = total_`v'/max_adult_size 
			else if inlist("`v'","leave_child","mig_child")  replace share_`v' = total_`v'/max_child_size
			else if inlist("`v'","leave_woman","mig_woman")  replace share_`v' = total_`v'/woman_size 
			else if inlist("`v'","leave_man","mig_man")      replace share_`v' = total_`v'/man_size 
			replace share_`v' = 0 if missing(share_`v')
		}

* Violence variables
bys id_hh year: gen tag_hhy = _n==1

		replace d_violence = 0 if missing(d_violence)
		replace deathwounded_100 = 0 if missing(deathwounded_100)
		
		bys id_hh: egen any_violence = max(d_violence)
		bys id_hh: egen years_violence = total(cond(tag_hhy, d_violence, .))
		bys id_hh: egen avg_deathwounded_100 = mean(cond(tag_hhy, deathwounded_100, .))

* Shocks variables
		local shocks sk_vl_rob_land sk_vl_rob_product sk_vl_rob_money sk_vl_rob_goods sk_vl_rob_destruction sk_jail sk_movi sk_att sk_kidnap sk_workforced sk_torture sk_contribution sk_nt_rain sk_nt_drought sk_nt_disease sk_nt_crop_bad sk_nt_destru_rain sk_nt_erosion  sk_ec_input_access sk_ec_input_price sk_ec_nonmarket sk_ec_output_price sk_ec_sell_land sk_ec_sell_other sk_ec_rec_help

		foreach v of local shocks {
			replace `v' = 0 if missing(`v')
		}

		foreach v of local shocks {
			bys id_hh: egen any_`v' = max(`v')
			bys id_hh: egen years_`v' = total(cond(tag_hhy, `v', .))
		}
		
* PCA variables
		local pcas pca_agri pca_asset pca_economic pca_coping pca_weather pca_natural pca_natural_all pca_all
		
		foreach x of local pcas {
			cap bys id_hh: egen `x'_mean = mean(cond(tag_hhy, `x', .))
			quietly summarize `x'_mean if n_hh == 1
			local cutoff_mean = r(mean)
			cap gen `x'_above_mean = (`x'_mean > `cutoff_mean') if `x'_mean < .
		}

* Household Baseline Characteristics 1998
		replace Poverty_status_98 = 0 if missing(Poverty_status_98)
		replace Poverty_status_07 = 0 if missing(Poverty_status_07)
		gen head1998 = (year==1998 & pid07==1)
		bys id_hh: egen hh_head_female_1998 = max(cond(head1998, sex, .))
		replace hh_head_female_1998 = 0 if missing(hh_head_female_1998)
		bys id_hh: egen hh_head_age_1998 = max(cond(head1998, age, .))
		egen age_mean = mean(hh_head_age_1998)
		replace hh_head_age_1998 = age_mean if missing(hh_head_age_1998)
		bys id_hh year: egen livestock_hhy = mean(livestock)
		bys id_hh: egen avg_livestock = mean(livestock_hhy)

* Village controls
		egen altitude_mean = mean(altitude_av__m_)
		replace altitude_av__m_ = altitude_mean if missing(altitude_av__m_)

		egen rainfall_mean = mean(rainfall_av__mm_)
		replace rainfall_av__mm_ = rainfall_mean if missing(rainfall_av__mm_)
		
		egen temp_mean = mean(temp_av)
		replace temp_av = temp_mean if missing(temp_av)
		
	run "do-files/labels.do"

*-------------------------------------------------------------------
* Models - SIGNIFICANT RESULTS ONLY
*------------------------------------------------------------------------
	keep if n_hh == 1
	
	global base_vars "any_violence years_violence avg_deathwounded_100 any_sk_vl_rob_land any_sk_vl_rob_product any_sk_vl_rob_money any_sk_vl_rob_goods any_sk_vl_rob_destruction any_sk_jail any_sk_movi any_sk_att any_sk_kidnap any_sk_workforced any_sk_torture any_sk_contribution any_sk_nt_rain any_sk_nt_drought any_sk_nt_disease  any_sk_nt_crop_bad any_sk_nt_destru_rain any_sk_nt_erosion any_sk_ec_input_access any_sk_ec_input_price any_sk_ec_nonmarket any_sk_ec_output_price any_sk_ec_sell_land any_sk_ec_sell_other any_sk_ec_rec_help years_sk_vl_rob_land years_sk_vl_rob_product years_sk_vl_rob_money years_sk_vl_rob_goods years_sk_vl_rob_destruction years_sk_jail years_sk_movi years_sk_att years_sk_kidnap years_sk_workforced years_sk_torture years_sk_contribution years_sk_nt_rain years_sk_nt_drought years_sk_nt_disease years_sk_nt_crop_bad years_sk_nt_destru_rain years_sk_nt_erosion  years_sk_ec_input_access years_sk_ec_input_price years_sk_ec_nonmarket years_sk_ec_output_price years_sk_ec_sell_land years_sk_ec_sell_other years_sk_ec_rec_help pca_agri_mean pca_asset_mean pca_economic_mean pca_coping_mean pca_weather_mean pca_natural_mean pca_natural_all_mean pca_all_mean"

	global controls "hh_head_female_1998 hh_head_age_1998 altitude_av__m_ rainfall_av__mm_ temp_av i.province"

* --- Create dataset to store significant results ---
clear
gen var_name = ""
gen estimate = .
gen stderr = .
gen pvalue = .
gen significant = ""
gen sample_type = ""
gen interaction_var = ""
gen n_obs = .
gen r2 = .
save "$path_results/significant_results_temp.dta", replace

* --- General (All sample) ---
global interactions "any_leave total_leave share_leave"

use "$path_work/data/final/panel_individual.dta", clear
run "do-files/00_DataPreliminaries_Akresh-etal_2025.do"

keep if numsplit==0
drop if age==.
drop age
gen age=year-born_year_07
drop if Code98==.
keep if restr_7==1
variables
qui include "$path_work/do-files/labels.do"

xtset id_person year
bys province year: gen province_trend=_n
merge m:1 id_hh year using "$path_work/data/job/pca.dta", nogen

rename year jaar
merge m:1 reczd numen numsplit pid07 jaar using "$path_work/data/origin/demofinal17.dta", keepusing(totexp_a98 TOTEXP_mae07 litm98) keep(1 3) nogen
rename jaar year

replace leave = 0 if missing(leave)
gen leave_adult  = (leave == 1 & adult_18 == 1) 
gen leave_child = (leave == 1 & adult_18 == 0) 
gen leave_woman = (leave == 1 & sex == 1) 
gen leave_man = (leave == 1 & sex == 0) 

local migration leave leave_adult leave_child leave_woman leave_man
bys id_hh year: gen hh_size = _N
egen woman_size = total(sex==1), by(id_hh year)
egen man_size = total(sex==0), by(id_hh year)
egen child_size = total(adult_18==0), by(id_hh year)
egen adult_size = total(adult_18==1), by(id_hh year)
bys id_hh: egen max_child_size = max(child_size)
bys id_hh: egen max_adult_size = max(adult_size)

foreach v of local migration {
	bys id_hh: egen any_`v' = max(`v')
	sort id_person year
	gen first_`v' = 0
	by id_person (year): replace first_`v' = `v'==1 & (`v'[_n-1]==0 | _n==1)
	bys id_hh year: egen total_`v'_year = total(first_`v')
	bys id_hh: egen total_`v' = total(first_`v')
	gen share_`v' = .
	if      inlist("`v'","leave")                    replace share_`v' = total_`v'/hh_size
	else if inlist("`v'","leave_adult","mig_adult")  replace share_`v' = total_`v'/max_adult_size 
	else if inlist("`v'","leave_child","mig_child")  replace share_`v' = total_`v'/max_child_size
	else if inlist("`v'","leave_woman","mig_woman")  replace share_`v' = total_`v'/woman_size 
	else if inlist("`v'","leave_man","mig_man")      replace share_`v' = total_`v'/man_size 
	replace share_`v' = 0 if missing(share_`v')
}

bys id_hh year: gen tag_hhy = _n==1
replace d_violence = 0 if missing(d_violence)
replace deathwounded_100 = 0 if missing(deathwounded_100)
bys id_hh: egen any_violence = max(d_violence)
bys id_hh: egen years_violence = total(cond(tag_hhy, d_violence, .))
bys id_hh: egen avg_deathwounded_100 = mean(cond(tag_hhy, deathwounded_100, .))

local shocks sk_vl_rob_land sk_vl_rob_product sk_vl_rob_money sk_vl_rob_goods sk_vl_rob_destruction sk_jail sk_movi sk_att sk_kidnap sk_workforced sk_torture sk_contribution sk_nt_rain sk_nt_drought sk_nt_disease sk_nt_crop_bad sk_nt_destru_rain sk_nt_erosion  sk_ec_input_access sk_ec_input_price sk_ec_nonmarket sk_ec_output_price sk_ec_sell_land sk_ec_sell_other sk_ec_rec_help

foreach v of local shocks {
	replace `v' = 0 if missing(`v')
}

foreach v of local shocks {
	bys id_hh: egen any_`v' = max(`v')
	bys id_hh: egen years_`v' = total(cond(tag_hhy, `v', .))
}

local pcas pca_agri pca_asset pca_economic pca_coping pca_weather pca_natural pca_natural_all pca_all

foreach x of local pcas {
	cap bys id_hh: egen `x'_mean = mean(cond(tag_hhy, `x', .))
	quietly summarize `x'_mean if n_hh == 1
	local cutoff_mean = r(mean)
	cap gen `x'_above_mean = (`x'_mean > `cutoff_mean') if `x'_mean < .
}

replace Poverty_status_98 = 0 if missing(Poverty_status_98)
replace Poverty_status_07 = 0 if missing(Poverty_status_07)
gen head1998 = (year==1998 & pid07==1)
bys id_hh: egen hh_head_female_1998 = max(cond(head1998, sex, .))
replace hh_head_female_1998 = 0 if missing(hh_head_female_1998)
bys id_hh: egen hh_head_age_1998 = max(cond(head1998, age, .))
egen age_mean = mean(hh_head_age_1998)
replace hh_head_age_1998 = age_mean if missing(hh_head_age_1998)
bys id_hh year: egen livestock_hhy = mean(livestock)
bys id_hh: egen avg_livestock = mean(livestock_hhy)

egen altitude_mean = mean(altitude_av__m_)
replace altitude_av__m_ = altitude_mean if missing(altitude_av__m_)

egen rainfall_mean = mean(rainfall_av__mm_)
replace rainfall_av__mm_ = rainfall_mean if missing(rainfall_av__mm_)

egen temp_mean = mean(temp_av)
replace temp_av = temp_mean if missing(temp_av)

run "do-files/labels.do"

keep if n_hh == 1

* --- Loop para todas las combinaciones y guardar solo significativas ---
local sig_results = 0

foreach sample_name in all adult child woman man {
	
	if "`sample_name'" == "all" {
		local sample_label "General (All)"
		global sample_interactions "any_leave total_leave share_leave"
	}
	else if "`sample_name'" == "adult" {
		local sample_label "Adult Migration"
		global sample_interactions "any_leave_adult total_leave_adult share_leave_adult"
	}
	else if "`sample_name'" == "child" {
		local sample_label "Child Migration"
		global sample_interactions "any_leave_child total_leave_child share_leave_child"
	}
	else if "`sample_name'" == "woman" {
		local sample_label "Woman Migration"
		global sample_interactions "any_leave_woman total_leave_woman share_leave_woman"
	}
	else if "`sample_name'" == "man" {
		local sample_label "Man Migration"
		global sample_interactions "any_leave_man total_leave_man share_leave_man"
	}
	
	foreach b of global base_vars {
		foreach z of global sample_interactions {
			
			* Regresión
			qui reg Poverty_status_07 Poverty_status_98 c.`b'##c.`z' $controls , vce(cluster reczd)
			
			* Guardar estimaciones con nombres de variables
			qui est store temp_model
			
			* Obtener p-valores y coeficientes
			matrix pvals = e(p)
			matrix coefs = e(b)
			matrix ses = e(se)
			
			* Número de columnas
			local ncols = colsof(coefs)
			
			* Iterar sobre los coeficientes
			forvalues col = 1/`ncols' {
				local pval = pvals[1, `col']
				
				if `pval' < 0.10 {
					local ++sig_results
					
					local est = coefs[1, `col']
					local se = ses[1, `col']
					local coef_name: colnames(coefs)[`col']
					
					* Determinar nivel de significancia
					if `pval' < 0.01 {
						local sig_level = "***"
					}
					else if `pval' < 0.05 {
						local sig_level = "**"
					}
					else {
						local sig_level = "*"
					}
					
					* Guardar en temporal
					use "$path_results/significant_results_temp.dta", clear
					
					local new_row = _N + 1
					set obs `new_row'
					
					replace var_name = "`coef_name'" in `new_row'
					replace estimate = `est' in `new_row'
					replace stderr = `se' in `new_row'
					replace pvalue = `pval' in `new_row'
					replace significant = "`sig_level'" in `new_row'
					replace sample_type = "`sample_label'" in `new_row'
					replace interaction_var = "`z'" in `new_row'
					replace n_obs = e(N) in `new_row'
					replace r2 = e(r2) in `new_row'
					
					save "$path_results/significant_results_temp.dta", replace
				}
			}
		}
	}
}

* --- Exportar resultados significativos a Excel ---
use "$path_results/significant_results_temp.dta", clear

* Mantener solo registros con datos
drop if var_name == ""

di ""
di "=========================================="
di "Resultados Significativos Encontrados: `sig_results'"
di "=========================================="

if _N > 0 {
	* Export to CSV
	export delimited using "$path_results/significant_results.csv", replace
	
	* Convert to Excel
	export excel using "$path_results/significant_results.xlsx", replace first(var)
	
	di "✓ Archivo guardado: significant_results.xlsx"
	di "  Filas: " _N
	di "  Columnas: variable, estimado, error estándar, p-value, significancia, tipo de muestra, variable de interacción"
}
else {
	di "⚠ No se encontraron resultados significativos"
}

di "=========================================="
di "Archivo: $path_results/significant_results.xlsx"
di "=========================================="

* Crear resumen de resultados significativos por tipo de muestra
use "$path_results/significant_results_temp.dta", clear
drop if var_name == ""

if _N > 0 {
	
	di ""
	di "Resumen de Resultados Significativos por Tipo de Muestra:"
	di "=========================================="
	
	* Contar por tipo de muestra
	quietly tab sample_type
	
	* Crear tabla resumen simple
	local sample_types: value label sample_type
	
	foreach sample in "General (All)" "Adult Migration" "Child Migration" "Woman Migration" "Man Migration" {
		quietly count if sample_type == "`sample'" & pvalue < 0.05
		local sig_005 = r(N)
		quietly count if sample_type == "`sample'" & pvalue < 0.10
		local sig_010 = r(N)
		
		if `sig_005' > 0 | `sig_010' > 0 {
			di "  `sample': `sig_005' (p<0.05), `sig_010' (p<0.10)"
		}
	}
}

* Limpiar archivos temporales
cap erase "$path_results/significant_results_temp.dta"

di ""
di "=========================================="
di "✓ Proceso completado"
di "=========================================="
