*--------------------------------------------*
*---- Civil War and Household Composition ---*
*------ Akresh, Muñoz and Verwimp (2025) ----*
*------ 	 TABLES HOUSEHOLD  		     ----*
*------ 	  July 1, 2025  		     ----*
*--------------------------------------------*
*--------------------------------------------*

* --- --- --- --- --- --- --- --- --- 
* Defining Working Paths  
* --- --- --- --- --- --- --- --- --- 
	clear all
    global path_work "/path/where/data/and/dofiles/are/located"
    global result_table "/path/where/tables/are/located" 
    global results "/excel/file/where/tables/are/located.xlsx" 
 
* --- --- --- --- --- --- --- --- --- 
* We include the data preliminaries 
* --- --- --- --- --- --- --- --- --- 
  
	run "$path_work/do-files/0_DataPreliminaries_Akresh-etal_2025.do"
  
* --- --- --- --- --- --- --- --- --- 
*  Sample 
* --- --- --- --- --- --- --- --- --- 

	* Only Parental household
		keep if numsplit==0
		drop if age==.
		drop age
		gen age=year-born_year_07
		*drop if born_year_07>1998
		* Registered household members
		drop if Code98==.

* --- --- --- --- --- --- --- --- --- 
* Set of Variables
* --- --- --- --- --- --- --- --- --- 

		global exposure "d_violence"
		global intensity "deathwounded_100"
		global tables_hh ""d_violence" "deathwounded_100"  "sk_vl_rob_land" "sk_vl_rob_product" "sk_vl_rob_money"  "sk_vl_rob_goods" "sk_vl_rob_destruction"   "pca_agri" "pca_asset" "pca_all""
		
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

		merge m:1 id_hh year using "$path_work/data/pca.dta", nogen
		
* --- --- --- --- --- --- --- --- --- 
* TABLE I
* Summary Statistics 1997-2008
* --- --- --- --- --- --- --- --- --- 
		
			putexcel set "${results}", modify sheet("Table 1") 

		* Individual-year level 
			estpost tabstat d_violence deathwounded_100 leave, stats(n mean sd)  columns(statistics) 

			putexcel C4=matrix(e(count)') D4=matrix(e(mean)') E4=matrix(e(sd)')  
	
		* Individual level 
			estpost tabstat d_leave_ind if n_ind==1, stats(n mean sd)  columns(statistics)  

			putexcel C8=matrix(e(count)') D8=matrix(e(mean)') E8=matrix(e(sd)')

	
		* Household-year level 
			estpost tabstat d_violence deathwounded_100 d_leave_hh leave_hh   sk_vl_rob_money sk_vl_rob_product sk_vl_rob_goods sk_vl_rob_destruction sk_vl_rob_land 	pca_agri pca_asset pca_all if hh==1,  stats(n mean sd)  columns(statistics)

			putexcel C10=matrix(e(count)') D10=matrix(e(mean)') E10=matrix(e(sd)')


		* Household Level 
			estpost tabstat hh_d_violence hh_deathwounded  leave_hh_t d_leave_hh_t hh_sk_vl_rob_money hh_sk_vl_rob_product hh_sk_vl_rob_goods hh_sk_vl_rob_destruction hh_sk_vl_rob_land if n_hh==1, stats(n mean sd)  columns(statistics)
			
			putexcel C22=matrix(e(count)') D22=matrix(e(mean)') E22=matrix(e(sd)')


		* Village-year level
			estpost tabstat v_deathwounded v_d_violence  if n_vill_y==1, stats(n mean sd)  columns(statistics)
			
			putexcel C32=matrix(e(count)') D32=matrix(e(mean)') E32=matrix(e(sd)') 


		* Village-year level		
		
			estpost tabstat v1_d_violence  if n_vill==1, stats(n mean sd)  columns(statistics)
			
			putexcel C35=matrix(e(count)') D35=matrix(e(mean)') E35=matrix(e(sd)') 
			
* --- --- --- --- --- --- --- --- --- 
* TABLE II
* Cross tabulation
* --- --- --- --- --- --- --- --- ---

		preserve
		* --- Preparación de muestra final: hogar único, migración no matrimonial ---
		bysort id_hh: keep if _n == 1  // un hogar por id

		* Panel A: dummy si hubo violencia en algún año en el village
		gen ever_violence = 0
		bysort id_hh: replace ever_violence = 1 if d_violence == 1

		* Panel B: intensidad acumulada
		bysort id_hh: egen total_casualties = total(deathwounded_100)
		sum total_casualties if !missing(total_casualties)
		gen casualties_above_mean = (total_casualties > r(mean)) if !missing(total_casualties)

		* --- Crear dummy PCA alta (sobre la media de índice de pérdidas del hogar) ---


		* --- Etiquetas para mayor claridad (opcional) ---
		label define vio 0 "No violence" 1 "Experienced violence"
		label define cas 0 "Below mean" 1 "Above mean"
		label values ever_violence vio
		label values casualties_above_mean cas

		* --- Panel A: violencia vs PCA ---
		display "=== Panel A: Violence exposure ==="
		table ever_violence pca_all_abovemean, ///
			statistic(count id_hh) statistic(mean d_leave_hh) 

		* --- Panel B: casualties vs PCA ---
		display "=== Panel B: Casualties exposure ==="
		table casualties_above_mean pca_all_abovemean, ///
			statistic(count id_hh) statistic(mean d_leave_hh) ///
			format(%9.0g %6.3f) row total

		restore
		
* --- --- --- --- --- --- --- --- --- 
* TABLE III
* Baseline results. Household migration
* --- --- --- --- --- --- --- --- ---

		cap drop hh
		bys id_hh year: gen hh = _n
		keep if hh == 1
		
		collapse (sum) d_leave_hh d_violence pca_all_sum = pca_all (mean) pca_all_mean = pca_all , by(id_hh)
		
		sum pca_all_mean if !missing(pca_all_mean)
		gen pca_all_abovemean = (pca_all_mean >= r(mean)) if !missing(pca_all_mean) 
		
		
		xtset id_hh year
		* --- Regressions
		eststo clear
		foreach j in $tables_hh {
			eststo:  xtreg d_leave_hh `j' i.year province_trend, cluster(reczd) fe 
		}

		*Export results
		
	
* --- --- --- --- --- --- --- --- ---  --- --- --- ---
* TABLE IV
* Baseline results with lags. Household migration
* --- --- --- --- --- --- --- --- --- --- --- --- ---	

		* Generate lags
		* Make sure panel is set
		xtset id_hh year
		
		* List of variables for which we want to generate lags
		local basevars ///
		d_violence deathwounded_100 ///
		sk_vl_rob_land sk_vl_rob_product sk_vl_rob_money sk_vl_rob_goods sk_vl_rob_destruction ///
		pca_agri pca_asset pca_all

		* Loop to generate lagged variables
		foreach var of local basevars {
			cap drop lag_`var'
			gen lag_`var' = L1.`var'
		}
		
			* --- Regressions
		eststo clear
		foreach j in $tables_hh {
			eststo: xtreg d_leave_hh `j' lag_`j'  i.year province_trend, cluster(reczd) fe 
		}
		
		*Export results
		
* --- --- --- --- --- --- --- --- ---  --- --- --- ---
* TABLE V
* Baseline results selected vars. Household migration
* --- --- --- --- --- --- --- --- --- --- --- --- ---	
		
		*  Variables to interact
		global base_vars5 "d_violence deathwounded_100"
		global pca_vars5 "pca_asset pca_all"

		* Run regressions combining each exposure and intensity with each PCA index
		eststo clear
		foreach x in $base_vars5 {
			foreach z in $pca_vars5 {
				
		* Regression with both conflict exposure and PCA index
			eststo:  xtreg d_leave_hh `x' `z' i.year province_trend, fe cluster(reczd)
			}
		}
		
		*Export results
		
* --- --- --- --- --- --- --- --- ---  --- --- --- ---
* TABLE VI
* Baseline results with interactions. Household migration
* --- --- --- --- --- --- --- --- --- --- --- --- ---	

		* Dummy: Number of casualties in a given year above mean (yes=1)
		sum deathwounded_100 if !missing(deathwounded_100)
		gen deathwounded_abovemean = (deathwounded_100 > r(mean)) if !missing(deathwounded_100)
		* Dummy: PCA above mean
		sum pca_all if !missing(pca_all)
		gen pca_all_abovemean = (pca_all > r(mean)) if !missing(pca_all)

		* --- Variables to interact ---
		global base_vars6 "d_violence deathwounded_100 deathwounded_abovemean"
		global pca_vars6 "pca_all_abovemean pca_all"
		
		* Run regressions interacting each exposure and intensity with each PCA index
		eststo clear
		foreach x in $base_vars6 {
			foreach z in $pca_vars6 {
				
		* Regression with interaction between conflict exposure and PCA index
		    eststo: xtreg d_leave_hh c.`x'##c.`z' i.year province_trend, fe cluster(reczd)
			}
		}
		
		*Export results
	
		
* --- --- --- --- --- --- --- --- ---  --- --- --- --- --- --- ---
* TABLE VII
* Baseline results with interactions and lags. Household migration
* --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---	

		* Generate lags
		gen lag_deathwounded_abovemean = L1.deathwounded_abovemean
		gen lag_pca_all_abovemean = L1.pca_all_abovemean
	
		* --- Variables to interact ---
		global base_vars7 "d_violence deathwounded_100 deathwounded_abovemean"
		global pca_vars7 "pca_all_abovemean pca_all"

				* Run regressions interacting each exposure and intensity with each PCA index
		eststo clear
		foreach x in $base_vars7 {
			foreach z in $pca_vars7 {
				
		* Regression with both conflict exposure and PCA index
			eststo: xtreg d_leave_hh c.`x'##c.`z' c.lag_`x'##c.lag_`z' i.year province_trend, fe cluster(reczd)
			}
		}
		
		*Export results
		