*--------------------------------------------*
*---- Civil War and Household Composition ---*
*------ Akresh, Muñoz and Verwimp (2025) ----*
*------ 	 TABLES HOUSEHOLD  		     ----*
*------ 	  July 1, 2025  		     ----*
*--------------------------------------------*
*--------------------------------------------*

* --- --- --- --- --- --- --- --- --- 
* We include the data preliminaries 
* --- --- --- --- --- --- --- --- --- 
  
	run "do-files/00_DataPreliminaries_Akresh-etal_2025.do"
	global results "$path_work/out/Akresh_etal_20250708_household.xlsx" 
  
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

		merge m:1 id_hh year using "$path_work/data/job/pca.dta", nogen
		
* --- --- --- --- --- --- --- --- --- 
* TABLE I
* Summary Statistics 1997-2008
* --- --- --- --- --- --- --- --- --- 
		
			putexcel set "${results}", modify sheet("Table 1") 

		* Individual-year level 
			estpost tabstat d_violence deathwounded_100 leave, stats(n mean sd)  columns(statistics) 

			putexcel C5=matrix(e(count)') D5=matrix(e(mean)') E5=matrix(e(sd)')  
	
		* Individual level 
			estpost tabstat d_leave_ind if n_ind==1, stats(n mean sd)  columns(statistics)  

			putexcel C9=matrix(e(count)') D9=matrix(e(mean)') E9=matrix(e(sd)')

	
		* Household-year level 
			estpost tabstat d_violence deathwounded_100 d_leave_hh leave_hh   sk_vl_rob_money sk_vl_rob_product sk_vl_rob_goods sk_vl_rob_destruction sk_vl_rob_land 	pca_agri pca_asset pca_all if hh==1,  stats(n mean sd)  columns(statistics)

			putexcel C11=matrix(e(count)') D11=matrix(e(mean)') E11=matrix(e(sd)')


		* Household Level 
			estpost tabstat hh_d_violence hh_deathwounded  leave_hh_t d_leave_hh_t hh_sk_vl_rob_money hh_sk_vl_rob_product hh_sk_vl_rob_goods hh_sk_vl_rob_destruction hh_sk_vl_rob_land pca_agri_hh pca_asset_hh pca_all_hh if n_hh==1, stats(n mean sd)  columns(statistics)
			
			putexcel C24=matrix(e(count)') D24=matrix(e(mean)') E24=matrix(e(sd)')


		* Village-year level
			estpost tabstat v_deathwounded v_d_violence  if n_vill_y==1, stats(n mean sd)  columns(statistics)
			
			putexcel C37=matrix(e(count)') D37=matrix(e(mean)') E37=matrix(e(sd)') 


		* Village-year level		
		
			estpost tabstat v1_d_violence  if n_vill==1, stats(n mean sd)  columns(statistics)
			
			putexcel C40=matrix(e(count)') D40=matrix(e(mean)') E40=matrix(e(sd)') 
			
* --- --- --- --- --- --- --- --- --- 
* TABLE II
* Cross tabulation
* --- --- --- --- --- --- --- --- ---
		preserve
		keep if n_hh==1 & !missing(d_leave_hh) & !missing(pca_all)
		* Generate household-level variables
		egen pca_mean=mean(pca_all_hh)
		egen deathwounded_mean=mean(hh_deathwounded_100)
		
		gen pca_above = (pca_all_hh >= pca_mean) 
		gen d_hh_deathwounded = (hh_deathwounded_100 >= deathwounded_mean) 

		* Generate household-level violence variables
		putexcel set "${results}", modify sheet("Table 2") 

		*** Violence 
		estpost tabstat  hh_d_violence if pca_above==0, by(hh_d_violence) stats(n)  columns(statistics)
		putexcel C6=matrix(e(count)')

		estpost tabstat  d_leave_hh_t if pca_above==0, by(hh_d_violence) stats(mean)  columns(statistics)
		putexcel D6=matrix(e(mean)')
		
		estpost tabstat  hh_d_violence if pca_above==1, by(hh_d_violence) stats(n)  columns(statistics)
		putexcel E6=matrix(e(count)')

		estpost tabstat  d_leave_hh_t if pca_above==1, by(hh_d_violence) stats(mean)  columns(statistics)
		putexcel F6=matrix(e(mean)')

		*** d_hh_deathwounded
		estpost tabstat  d_hh_deathwounded if pca_above==0, by(d_hh_deathwounded) stats(n)  columns(statistics)
		putexcel C11=matrix(e(count)')

		estpost tabstat  d_leave_hh_t if pca_above==0, by(d_hh_deathwounded) stats(mean)  columns(statistics)
		putexcel D11=matrix(e(mean)')
		
		estpost tabstat  d_hh_deathwounded if pca_above==1, by(d_hh_deathwounded) stats(n)  columns(statistics)
		putexcel E11=matrix(e(count)')

		estpost tabstat  d_leave_hh_t if pca_above==1, by(d_hh_deathwounded) stats(mean)  columns(statistics)
		putexcel F11=matrix(e(mean)')

		
		restore


 *** AS All tables are at the household le 
 keep if hh==1
 xtset id_hh year

* --- --- --- --- --- --- --- --- --- 
* TABLE III
* Baseline results. Household migration
* --- --- --- --- --- --- --- --- ---
		
		putexcel set "$results", sheet("Table 3") modify  

		* --- Regressions
		eststo clear
		foreach j of global tables_hh {
			quietly xtreg d_leave_hh `j' i.year province_trend, fe cluster(reczd)
			
			*store the mean
			quietly summarize d_leave_hh if e(sample)
			estadd scalar depmean = r(mean)  

			eststo `j'                            
		}

		*** Export results to Excel

		local col = 3
		local row = 5
		local row_s = 27      

		foreach j of global tables_hh {

			*------------------------------------------------------------
			* 1. Recupera el modelo
			*------------------------------------------------------------
			est restore `j'

			*------------------------------------------------------------
			* 2. Extrae coeficiente, EE y p-valor
			*------------------------------------------------------------
			scalar b  = _b[`j']
			scalar se = _se[`j']
			scalar p  = 2*ttail(e(df_r), abs(b/se))
			scalar depm = e(depmean)
			scalar obs  = e(N)

			*------------------------------------------------------------
			* 3. Construye las estrellitas
			*------------------------------------------------------------
			local stars ""
			if      (p < .01) local stars "***"
			else if (p < .05) local stars "**"
			else if (p < .10) local stars "*"

			*------------------------------------------------------------
			* 4. Da formato
			*------------------------------------------------------------
			local b_fmt  : display %9.3f b
			local depm  : display %9.3f depm
			local obs : display %9.0f obs
			local se_fmt : display %9.3f se

			*------------------------------------------------------------
			* 5. Coeficientes
			*------------------------------------------------------------
			putexcel `=char(`col'+64)'`row' = ("`b_fmt'`stars'"), overwrite
			local r1=`row'+1
			putexcel `=char(`col'+64)'`r1' = ("[`se_fmt']"), overwrite

			
			*------------------------------------------------------------
			* 6. Estadísticas regresiones
			*------------------------------------------------------------
			putexcel `=char(`col'+64)'`row_s' = ("`obs'"), overwrite
			local row_s1=`row_s'+1
			putexcel `=char(`col'+64)'`row_s1' = ("`depm'"), overwrite

			*------------------------------------------------------------
			* 7. Prepara la siguiente variable:
			*    baja dos filas (coef + EE) y mantiene la misma columna
			*------------------------------------------------------------
			local row = `row' + 2
			local col = `col' + 1
		}


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
			foreach j of global tables_hh {
			quietly xtreg d_leave_hh `j' lag_`j' i.year province_trend, fe cluster(reczd)
			
			*store the mean
			quietly summarize d_leave_hh if e(sample)
			estadd scalar depmean = r(mean)  

			eststo `j'                            
		}



		*** Export results to Excel
		putexcel set "$results", sheet("Table 4") modify  

		local col = 3
		local row = 5
		local row_s = 46      

		foreach j of global tables_hh {

			*------------------------------------------------------------
			* 1. Recupera el modelo
			*------------------------------------------------------------
			est restore `j'

			*------------------------------------------------------------
			* 2. Extrae coeficiente, EE y p-valor
			*------------------------------------------------------------
			scalar b  = _b[`j']
			scalar bL  = _b[lag_`j']
			scalar se = _se[`j']
			scalar seL = _se[lag_`j']
			scalar p  = 2*ttail(e(df_r), abs(b/se))
			scalar pL  = 2*ttail(e(df_r), abs(bL/seL))

			scalar depm = e(depmean)
			scalar obs  = e(N)

			*------------------------------------------------------------
			* 3. Construye las estrellitas
			*------------------------------------------------------------
			local stars ""
			if      (p < .01) local stars "***"
			else if (p < .05) local stars "**"
			else if (p < .10) local stars "*"

			local starsL ""
			if (pL<.01)      local starsL "***"
			else if (pL<.05) local starsL "**"
			else if (pL<.10) local starsL "*"

			*------------------------------------------------------------
			* 4. Da formato
			*------------------------------------------------------------
			local bL_fmt  : display %9.3f bL
			local seL_fmt : display %9.3f seL
			
			local b_fmt  : display %9.3f b
			local se_fmt : display %9.3f se
			
			local depm  : display %9.3f depm
			local obs : display %9.0f obs
			

			*------------------------------------------------------------
			* 5. Coeficientes
			*------------------------------------------------------------
			putexcel `=char(`col'+64)'`row' = ("`b_fmt'`stars'"), overwrite
			local r1=`row'+1
			putexcel `=char(`col'+64)'`r1' = ("[`se_fmt']"), overwrite
			local r2=`row'+2
			putexcel `=char(`col'+64)'`r2' = ("`bL_fmt'`stars'"), overwrite
			local r3=`row'+3
			putexcel `=char(`col'+64)'`r3' = ("[`seL_fmt']"), overwrite

			*------------------------------------------------------------
			* 6. Estadísticas regresiones
			*------------------------------------------------------------
			putexcel `=char(`col'+64)'`row_s' = ("`obs'"), overwrite
			local row_s1=`row_s'+1
			putexcel `=char(`col'+64)'`row_s1' = ("`depm'"), overwrite

			*------------------------------------------------------------
			* 7. Prepara la siguiente variable:
			*    baja dos filas (coef + EE) y mantiene la misma columna
			*------------------------------------------------------------
			local row = `row' + 4
			local col = `col' + 1
		}

		
* --- --- --- --- --- --- --- --- ---  --- --- --- ---
* TABLE V
* Baseline results selected vars. Household migration
* --- --- --- --- --- --- --- --- --- --- --- --- ---	
		
		*  Variables to interact
		global base_vars5 "d_violence deathwounded_100"
		global pca_vars5 "pca_asset pca_all"

		* Run regressions combining each exposure and intensity with each PCA index
		loc r=1
		eststo clear
		foreach x in $base_vars5 {
			foreach z in $pca_vars5 {
				
			* Regression with both conflict exposure and PCA index
			eststo:  xtreg d_leave_hh `x' `z' i.year province_trend, fe cluster(reczd)

			*store the mean
			quietly summarize d_leave_hh if e(sample)
			estadd scalar depmean = r(mean)  

			eststo r`r'
			local r=`r'+1  

			}
		}

		*** Export results to Excel
		putexcel set "$results", sheet("Table 4") modify  

		local col = 3
		local row = 5
		local row_s = 46      

		foreach j of global tables_hh {

			*------------------------------------------------------------
			* 1. Recupera el modelo
			*------------------------------------------------------------
			est restore `j'

			*------------------------------------------------------------
			* 2. Extrae coeficiente, EE y p-valor
			*------------------------------------------------------------
			scalar b  = _b[`j']
			scalar bL  = _b[lag_`j']
			scalar se = _se[`j']
			scalar seL = _se[lag_`j']
			scalar p  = 2*ttail(e(df_r), abs(b/se))
			scalar pL  = 2*ttail(e(df_r), abs(bL/seL))

			scalar depm = e(depmean)
			scalar obs  = e(N)

			*------------------------------------------------------------
			* 3. Construye las estrellitas
			*------------------------------------------------------------
			local stars ""
			if      (p < .01) local stars "***"
			else if (p < .05) local stars "**"
			else if (p < .10) local stars "*"

			local starsL ""
			if (pL<.01)      local starsL "***"
			else if (pL<.05) local starsL "**"
			else if (pL<.10) local starsL "*"

			*------------------------------------------------------------
			* 4. Da formato
			*------------------------------------------------------------
			local bL_fmt  : display %9.3f bL
			local seL_fmt : display %9.3f seL
			
			local b_fmt  : display %9.3f b
			local se_fmt : display %9.3f se
			
			local depm  : display %9.3f depm
			local obs : display %9.0f obs
			

			*------------------------------------------------------------
			* 5. Coeficientes
			*------------------------------------------------------------
			putexcel `=char(`col'+64)'`row' = ("`b_fmt'`stars'"), overwrite
			local r1=`row'+1
			putexcel `=char(`col'+64)'`r1' = ("[`se_fmt']"), overwrite
			local r2=`row'+2
			putexcel `=char(`col'+64)'`r2' = ("`bL_fmt'`stars'"), overwrite
			local r3=`row'+3
			putexcel `=char(`col'+64)'`r3' = ("[`seL_fmt']"), overwrite

			*------------------------------------------------------------
			* 6. Estadísticas regresiones
			*------------------------------------------------------------
			putexcel `=char(`col'+64)'`row_s' = ("`obs'"), overwrite
			local row_s1=`row_s'+1
			putexcel `=char(`col'+64)'`row_s1' = ("`depm'"), overwrite

			*------------------------------------------------------------
			* 7. Prepara la siguiente variable:
			*    baja dos filas (coef + EE) y mantiene la misma columna
			*------------------------------------------------------------
			local row = `row' + 4
			local col = `col' + 1
		}
		



		
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
		
		* Export results to Excel - Table VI
		putexcel set "${results}", modify sheet("Table 6")
		esttab using "${results}", sheet("Table 6") modify ///
			keep($base_vars6 $pca_vars6 *.`*'#*.`*') ///
			cells(b(star fmt(3)) se(par fmt(3))) ///
			startcol(3) startrow(5)
	
		
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
		
		* Export results to Excel - Table VII
		putexcel set "${results}", modify sheet("Table 7")
		esttab using "${results}", sheet("Table 7") modify ///
			keep($base_vars7 $pca_vars7 lag_* *.`*'#*.`*') ///
			cells(b(star fmt(3)) se(par fmt(3))) ///
			startcol(3) startrow(5)
