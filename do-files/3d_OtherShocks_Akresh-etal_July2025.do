*--------------------------------------------*
*---- Civil War and Household Composition ---*
*------ Akresh, Muñoz and Verwimp (2025) ----*
*------ 	 OTHER SHOCKS  		 ----*
*------ 	  July 2, 2025  		     ----*
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
*  PCA
* --- --- --- --- --- --- --- --- --- 

		merge m:1 id_hh year using "$path_work/data/pca.dta", nogen

* --- --- --- --- --- --- --- --- --- 
* Set of Variables
* --- --- --- --- --- --- --- --- --- 

		global exposure "d_violence"
		global intensity "deathwounded_100"
		global tables "sk_kidnap sk_workforced sk_torture sk_contribution sk_nt_rain sk_nt_drought sk_nt_disease sk_nt_crop_bad sk_nt_crop_good sk_nt_destru_rain sk_nt_erosion sk_ec_input_access sk_ec_input_price sk_ec_nonmarket sk_ec_output_price sk_ec_sell_land  sk_ec_sell_other sk_ec_rec_help"
		
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

		foreach var in sk_kidnap sk_workforced sk_torture sk_contribution sk_nt_rain sk_nt_drought sk_nt_disease ///
					  sk_nt_crop_bad sk_nt_crop_good sk_nt_destru_rain sk_nt_erosion sk_ec_input_access ///
					  sk_ec_input_price sk_ec_nonmarket sk_ec_output_price sk_ec_sell_land ///
					  sk_ec_sell_other sk_ec_rec_help cff_coffee  {
			replace `var' = 0 if missing(`var')
			}
		foreach var in sk_kidnap sk_workforced sk_torture sk_contribution sk_nt_rain sk_nt_drought sk_nt_disease ///
					  sk_nt_crop_bad sk_nt_crop_good sk_nt_destru_rain sk_nt_erosion sk_ec_input_access ///
					  sk_ec_input_price sk_ec_nonmarket sk_ec_output_price sk_ec_sell_land ///
					  sk_ec_sell_other sk_ec_rec_help cff_coffee   {
			replace `var' = 0 if `var' != 1
			}
			* For binary variables - Generating independent variables by HH 
        foreach i in $tables {
				gsort id_hh year - `i'
				bys id_hh year: gen hh_`i'=`i'[_n-1] if `i'!=`i'[_n-1] & `i'[_n-1]!=.
				replace hh_`i'=0 if hh_`i'==.
				}	
			
			
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
			estpost tabstat d_violence deathwounded_100 d_leave_hh leave_hh  sk_vl_rob_money sk_vl_rob_product sk_vl_rob_goods sk_vl_rob_destruction sk_vl_rob_land pca_agri pca_asset pca_all  sk_kidnap sk_workforced sk_torture sk_contribution sk_nt_rain sk_nt_drought sk_nt_disease ///
					  sk_nt_crop_bad sk_nt_crop_good sk_nt_destru_rain sk_nt_erosion sk_ec_input_access ///
					  sk_ec_input_price sk_ec_nonmarket sk_ec_output_price sk_ec_sell_land ///
					  sk_ec_sell_other sk_ec_rec_help cff_coffee cff_tree cff_income livestock if hh==1,  stats(n mean sd)  columns(statistics)

			putexcel C10=matrix(e(count)') D10=matrix(e(mean)') E10=matrix(e(sd)')


		* Household Level 
			estpost tabstat hh_d_violence hh_deathwounded  leave_hh_t d_leave_hh_t hh_sk_vl_rob_money hh_sk_vl_rob_product hh_sk_vl_rob_goods hh_sk_vl_rob_destruction hh_sk_vl_rob_land pca_agri pca_asset pca_all  sk_kidnap sk_workforced sk_torture sk_contribution sk_nt_rain sk_nt_drought sk_nt_disease ///
					  sk_nt_crop_bad sk_nt_crop_good sk_nt_destru_rain sk_nt_erosion sk_ec_input_access ///
					  sk_ec_input_price sk_ec_nonmarket sk_ec_output_price sk_ec_sell_land if n_hh==1, stats(n mean sd)  columns(statistics)
			
			putexcel C22=matrix(e(count)') D22=matrix(e(mean)') E22=matrix(e(sd)')


		* Village-year level
			estpost tabstat v_deathwounded v_d_violence  if n_vill_y==1, stats(n mean sd)  columns(statistics)
			
			putexcel C32=matrix(e(count)') D32=matrix(e(mean)') E32=matrix(e(sd)') 


		* Village-year level		
		
			estpost tabstat v1_d_violence  if n_vill==1, stats(n mean sd)  columns(statistics)
			
			putexcel C35=matrix(e(count)') D35=matrix(e(mean)') E35=matrix(e(sd)') 
			
* --- --- --- --- --- --- --- --- --- 
* TABLE II
* --- --- --- --- --- --- --- --- ---
	
		* --- Regressions
		eststo clear
		foreach j in $tables {
			eststo: xtreg leave `j' i.year province_trend, cluster(reczd) fe 
		}
		
* --- --- --- --- --- --- --- --- --- 
* TABLE III
* --- --- --- --- --- --- --- --- ---	
		cap drop hh
		bys id_hh year: gen hh=_n
		keep if hh==1
		xtset id_hh year
		eststo clear
		foreach j in $tables {
			eststo: xtreg leave `j' i.year province_trend, cluster(reczd) fe 
		}
		