*--------------------------------------------*
*---- Civil War and Household Composition ---*
*------ Akresh, Muñoz and Verwimp (2025) ----*
*------ 	 TABLES INDIVIDUAL  		 ----*
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

		merge m:1 id_hh year using "$path_work/data/pca.dta", nogen keep(3)

* --- --- --- --- --- --- --- --- --- 
* Set of Variables
* --- --- --- --- --- --- --- --- --- 

		global exposure "d_violence"
		global intensity "deathwounded_100"
		global tables ""d_violence" "deathwounded_100"  "sk_vl_rob_land" "sk_vl_rob_product" "sk_vl_rob_money"  "sk_vl_rob_goods" "sk_vl_rob_destruction"   "pca_agri" "pca_asset" "pca_all" "pca_natural_all" "pca_weather" "pca_natural""
		
		
* --- --- --- --- --- --- --- --- --- 
* TABLE I
* --- --- --- --- --- --- --- --- ---
		global base_vars1 ""d_violence" "deathwounded_100"  "sk_vl_rob_land" "sk_vl_rob_product" "sk_vl_rob_money"  "sk_vl_rob_goods" "sk_vl_rob_destruction"   "pca_agri" "pca_asset" "pca_all""
		global natural_vars1 " "pca_natural_all" "pca_weather" "pca_natural""
		
		* --- Regressions
		eststo clear
		foreach x in $base_vars1 {
			foreach z in $natural_vars1 {
				
			eststo: xtreg leave `x' `z' i.year province_trend, fe cluster(reczd)
			}
		}

* --- --- --- --- --- --- --- --- --- 
* TABLE II
* --- --- --- --- --- --- --- --- ---

