*--------------------------------------------*
*---- Civil War and Household Composition ---*
*------ Akresh, Muñoz and Verwimp (2025) ----*
*------ 	 TABLES INDIVIDUAL  		 ----*
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
		
* --- --- --- --- --- --- --- --- --- 
*  PCA
* --- --- --- --- --- --- --- --- --- 

		merge m:1 id_hh year using "$path_work/data/pca.dta", keep (3) nogen
		
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
			estpost tabstat d_violence deathwounded_100 d_leave_hh leave_hh   sk_vl_rob_money sk_vl_rob_product sk_vl_rob_goods sk_vl_rob_destruction sk_vl_rob_land pca_agri pca_asset pca_all if hh==1,  stats(n mean sd)  columns(statistics)

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


* --- --- --- --- --- --- --- --- --- 
* TABLE III
* --- --- --- --- --- --- --- --- ---

		drop province_trend
		bys province year: gen province_trend=_n
				
		* --- Regressions
		eststo clear
		foreach j in $tables_hh {
			eststo: xtreg leave `j' i.year province_trend, cluster(reczd) fe 
		}
		
		
* --- --- --- --- --- --- --- --- --- --- ---
* TABLE IV CUIDADO
* --- --- --- --- --- --- --- --- --- --- ---

		eststo clear
		foreach sample in "if sex==1" "if sex==0" "if adult_18==1" "if adult_18==0" "if pov_stat98==1" "if pov_stat98==0" {

				* Exposure
			eststo: xtreg leave $exposure $intensity pca_asset pca_all i.year province_trend `sample' , cluster(reczd) fe 

				}
				
* --- --- --- --- --- --- --- --- --- --- ---
* TABLE V
* --- --- --- --- --- --- --- --- --- --- ---

		* Generate lag
		xtset id_person year
		* List of variables for which we want to generate lags
		local basevars ///
		d_violence deathwounded_100 ///
		sk_vl_rob_land sk_vl_rob_product sk_vl_rob_money sk_vl_rob_goods sk_vl_rob_destruction ///
		pca_agri pca_asset pca_all
		
		
		* Loop to generate lagged variableS
		foreach var of local basevars {
			cap drop lag_`var'
			gen lag_`var' = L1.`var'
		}
		
		* --- Regressions
		eststo clear
		foreach j in $tables_hh {
			eststo: xtreg leave `j' lag_`j'  i.year province_trend, cluster(reczd) fe 
		}
		
		* Export results 
		
* --- --- --- --- --- --- --- --- --- --- ---
* TABLE VI
* --- --- --- --- --- --- --- --- --- --- ---

		*  Variables
		global base_vars6 "d_violence deathwounded_100 pca_agri pca_asset pca_all"

		foreach var in $base_vars6 {
			global base_vars6 "$base_vars6 lag_`var'"
		}

		* Estimate subgroup regressions
		eststo clear
		foreach sample in "if sex==1" "if sex==0" "if adult_18==1" "if adult_18==0" "if pov_stat98==1" "if pov_stat98==0" {
			eststo: xtreg leave $base_vars6 i.year province_trend `sample', cluster(reczd) fe 
		}
		
* --- --- --- --- --- --- --- --- --- --- --- --- ---
* TABLE VII
* --- --- --- --- --- --- --- --- --- --- --- --- ---
		
		*  Variables to interact
		global base_vars7 "d_violence deathwounded_100"
		global pca_vars7 "pca_asset pca_all"

		* Run regressions combining each exposure and intensity with each PCA index
		eststo clear
		foreach x in $base_vars7 {
			foreach z in $pca_vars7 {
				
		* Regression with both conflict exposure and PCA index
			eststo: xtreg leave `x' `z' i.year province_trend, fe cluster(reczd)
			}
		}
		
		*Export results
		
		
* --- --- --- --- --- --- --- --- --- --- --- --- ---
* TABLE VIII
* --- --- --- --- --- --- --- --- --- --- --- --- ---

		* Dummy: Number of casualties in a given year above mean (yes=1)
		sum deathwounded_100 if !missing(deathwounded_100)
		gen deathwounded_abovemean = (deathwounded_100 > r(mean)) if !missing(deathwounded_100)

		* --- Variables to interact ---
		global base_vars8 "d_violence deathwounded_100 deathwounded_abovemean"
		global pca_vars8 "pca_all_abovemean pca_all"
		
		* Run regressions interacting each exposure and intensity with each PCA index
		eststo clear
		foreach x in $base_vars8 {
			foreach z in $pca_vars8 {
				
		* Regression with interaction between conflict exposure and PCA index
		    eststo: xtreg leave c.`x'##c.`z' i.year province_trend, fe cluster(reczd)
			}
		}
		
		*Export results

* --- --- --- --- --- --- --- --- --- --- --- --- ---
* TABLE IX
* --- --- --- --- --- --- --- --- --- --- --- --- ---

		* Estimate subgroup regressions
		eststo clear
		foreach sample in "if sex==1" "if sex==0" "if adult_18==1" "if adult_18==0" "if pov_stat98==1" "if pov_stat98==0" {
			eststo: xtreg leave deathwounded_abovemean##pca_all_abovemean i.year province_trend `sample', cluster(reczd) fe 
		}
		
		*Export results

* --- --- --- --- --- --- --- --- --- --- --- --- ---
* TABLE X
* --- --- --- --- --- --- --- --- --- --- --- --- ---

		* --- Variables to interact ---
		global base_vars10 "d_violence deathwounded_100 deathwounded_abovemean"
		global pca_vars10 "pca_all_abovemean pca_all"
		
		xtset id_person year
		
		gen lag_pca_all_abovemean = L1.pca_all_abovemean
		gen lag_deathwounded_abovemean = L1.deathwounded_abovemean
		
		* Run regressions interacting each exposure and intensity with each PCA index
		eststo clear
		foreach x in $base_vars10 {
			foreach z in $pca_vars10 {
				
		* Regression with both conflict exposure and PCA index
			eststo: xtreg leave c.`x'##c.`z' c.lag_`x'##c.lag_`z' i.year province_trend, fe cluster(reczd)
			}
		}
		
* --- --- --- --- --- --- --- --- --- --- --- --- ---
* TABLE XI
* --- --- --- --- --- --- --- --- --- --- --- --- ---

		* Estimate subgroup regressions
		eststo clear
		foreach sample in "if sex==1" "if sex==0" "if adult_18==1" "if adult_18==0" "if pov_stat98==1" "if pov_stat98==0" {
			eststo: xtreg leave deathwounded_abovemean##pca_all_abovemean lag_deathwounded_abovemean##lag_pca_all_abovemean i.year province_trend `sample', cluster(reczd) fe 
		}
		
		*Exportar resultados
