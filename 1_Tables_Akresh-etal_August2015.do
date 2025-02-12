*--------------------------------------------*
*---- Civil War and Household Composition ---*
*------ Akresh, Muñoz and Verwimp (2015) ----*
*------ 		TABLES    										----*
*------ 		July 24, 2015								 ----*
*--------------------------------------------*
*--------------------------------------------*

* --- --- --- --- --- --- --- --- --- 
* Defining Working Paths  
* --- --- --- --- --- --- --- --- --- 

  global path_work "/Users/jcmunozmora/Documents/data/Akresh-Verwimp-Munoz"
  global results "/Users/jcmunozmora/Documents/Tesis/Chap 5 - Household Composition and Civil War/results/Akresh_etal-August2015_final.xlsx"
   global result_table "/Users/jcmunozmora/Documents/Tesis/Chap 5 - Household Composition and Civil War/results/"
  global mysintaxis "/Users/jcmunozmora/Documents/data/mysintaxis"
 
* Log-File
	cap log close
  log using "$path_work/log-files/Akresh-etal_2015", replace

* --- --- --- --- --- --- --- --- --- 
* We include the data preliminaries 
* --- --- --- --- --- --- --- --- --- 
	
	run "$path_work/do-files/0_DataPreliminaries_Akresh-etal_2015.do"

* --- --- --- --- --- --- --- --- --- 
* Corrected Sample 
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
		global tables_hh ""d_violence" "deathwounded_100"  "sk_vl_rob_land" "sk_vl_rob_product" "sk_vl_rob_money"  "sk_vl_rob_goods" "sk_vl_rob_destruction"   "index_agri" "index_asset""

*************************************
*** Baseline Sample (Tables I to II)
*** NON-MARRIAGE MIGRATION 
************************************* 
	preserve
	keep if restr_7==1
	variables
	qui include "$path_work/do-files/labels.do" 

	* Gen Province time trend
	xtset id_person year
	bys province year: gen province_trend=_n


* --- --- --- --- --- --- --- --- --- 
* TABLE I
* Summary Statistics 1997-2008 (OK)
* --- --- --- --- --- --- --- --- --- 

		* Individual-year level 
			estpost tabstat d_violence deathwounded_100 leave, stats(n mean sd)  columns(statistics) 

			putexcel C4=matrix(e(count)') D4=matrix(e(mean)') E4=matrix(e(sd)')using "${results}", modify   sheet("Table 1") keepcellformat 
	
		* Individual level 
			estpost tabstat d_leave_ind if n_ind==1, stats(n mean sd)  columns(statistics)  

			putexcel C8=matrix(e(count)') D8=matrix(e(mean)') E8=matrix(e(sd)')using "${results}", modify   sheet("Table 1") keepcellformat 

	
		* Household-year level 
			estpost tabstat d_violence deathwounded_100 d_leave_hh leave_hh   sk_vl_rob_money sk_vl_rob_product sk_vl_rob_goods sk_vl_rob_destruction sk_vl_rob_land 	index_agri index_asset if hh==1,  stats(n mean sd)  columns(statistics)

			putexcel C10=matrix(e(count)') D10=matrix(e(mean)') E10=matrix(e(sd)') using "${results}", modify   sheet("Table 1") keepcellformat 


		* Household Level 
			estpost tabstat hh_d_violence hh_deathwounded  leave_hh_t d_leave_hh_t hh_sk_vl_rob_money hh_sk_vl_rob_product hh_sk_vl_rob_goods hh_sk_vl_rob_destruction hh_sk_vl_rob_land if n_hh==1, stats(n mean sd)  columns(statistics)
			
			putexcel C22=matrix(e(count)') D22=matrix(e(mean)') E22=matrix(e(sd)') using "${results}", modify   sheet("Table 1") keepcellformat 


		* Village-year level
			estpost tabstat v_deathwounded v_d_violence  if n_vill_y==1, stats(n mean sd)  columns(statistics)
			
			putexcel C32=matrix(e(count)') D32=matrix(e(mean)') E32=matrix(e(sd)') using "${results}", modify   sheet("Table 1") keepcellformat 


		* Village-year level		
		
			estpost tabstat v1_d_violence  if n_vill==1, stats(n mean sd)  columns(statistics)
			
			putexcel C35=matrix(e(count)') D35=matrix(e(mean)') E35=matrix(e(sd)') using "${results}", modify   sheet("Table 1") keepcellformat 

* --- --- --- --- --- --- --- --- --- 
* TABLE II
* Migration by violence presence (OK)
* --- --- --- --- --- --- --- --- ---
	clear results
	clear matrix
	** Creating variables

		*Duration (temporary migration)
		gen duration=temp_return-temp_departure if type_people==2
		gen x=1

		*Village
		
		gen d_migration=1 if type_people==1|type_people==2
		replace d_migration=0 if d_migration==.
		label def d_migration 1 "Migration" 0 "No Migration"
		label val d_migration d_migration
		

	** Generating the Table

		estpost tabulate  d_migration v1_d_violence
		mat per=e(b)
		mat dif_mat =e(colpct)
		local dif=(dif_mat[1,2]-dif_mat[1,5])

		ttest d_migration, by(v1_d_violence)

		local sd_1  : display "[" int(r(sd_1)*100000)/1000  "]"
		local sd_2  : display "[" int(r(sd_2)*100000)/1000  "]"
		local se  : display "(0"  int(r(se)*100000)/1000  ")"

			if `r(p)'<=0.1 & `r(p)'>0.05 {
			local dif  : display int(`dif'*1000)/1000  "*"
			}

			if `r(p)'<=0.05  & `r(p)'>0.01 {
			local dif  : display int(`dif'*1000)/1000  "**"
			}

			if `r(p)'<=0.01 {
			local dif  : display  int(`dif'*1000)/1000  "***"
			}

			ttest duration, by(v1_d_violence)

			local sd_1a  : display "["  int(r(sd_1)*1000)/1000  "]"
			local sd_2a  : display "["  int(r(sd_2)*1000)/1000  "]"
			local se_a  : display "(0"  int(r(se)*1000)/1000  ")"
			local dif1=r(mu_1)-r(mu_2)

			if `r(p)'<=0.1 & `r(p)'>0.05 {
			local dif1  : display int(`dif1'*1000)/1000  "*"
			}

			if `r(p)'<=0.05  & `r(p)'>0.01 {
			local dif1  : display int(`dif1'*1000)/1000  "**"
			}

			if `r(p)'<=0.01 {
			local dif1  : display  int(`dif1'*1000)/1000  "***"
			}

		putexcel C4=(per[1,2]) C6=(per[1,1]) E4=(per[1,5]) E6=(per[1,4]) D5=("`sd_1'") F5=("`sd_2'") G5=("`se'") G4=("`dif'") C10=(r(mu_1)) E10=(r(mu_2) ) C11=("`sd_1a'") E11=("`sd_2a'") G11=("`se_a'") G10=("`dif1'") using "${results}", modify sheet("Table 2") keepcellformat 

* --- --- --- --- --- --- --- --- --- 
* TABLE III
* Individual migration (no-marriage) and Civil War
* --- --- --- --- --- --- --- --- ---
	
	* BASELINE RESULTS 
		* Set of variables for the analysis

			* Column I: Baseline
				
				eststo clear
				local j=1
				foreach sample in "" "if sex==1" "if sex==0" "if adult_18==1" "if adult_18==0" "if pov_stat98==1" "if pov_stat98==0" {

					* Exposure
				eststo: qui xtreg leave $exposure  i.year province_trend `sample' , cluster(reczd) fe 

					* Intensity 
				eststo: qui xtreg leave $intensity  i.year province_trend `sample' , cluster(reczd) fe 
					}

					* Export estout (To check)
					esttab using "$result_table/Table_3.csv", star(* 0.10 ** 0.05 *** 0.01) replace nomtitles brackets label se(%9.3f) b(%9.3f) fragment keep($exposure $intensity)


* --- --- --- --- --- --- --- --- --- 
* TABLE IV
* Household Migration (OK)
* --- --- --- --- --- --- --- --- ---

	
	*** Analysis at Household level (Tables I to II) 

		cap bys id_hh year: gen hh=_n		
		keep if hh==1
		xtset id_hh year
		drop province_trend
		bys province year: gen province_trend=_n

	
	* Regressions 
					
			eststo clear
		local i=1
		foreach j in  $tables_hh {
		eststo:qui xtreg d_leave_hh `j' i.year province_trend , cluster(reczd) fe
		}
		
		* Export estout (To check)
					esttab using "$result_table/Table_4.csv", star(* 0.10 ** 0.05 *** 0.01) replace nomtitles brackets label se(%9.3f) b(%9.3f) fragment keep($tables_hh


**************************************
*** Marriage Sample (Tables V to VI)
*** MARRIAGE MIGRATION 
** Sample all women 
*************************************

			* New Sample
						cap restore
						preserve

					* The sample
					* Women: No marriage at 1998
					* In Marital Age
					keep if sex==1
					drop if civil_98==2
					drop if age<15 & age>45
					variables

					* Gen Our New Dependent Variable
					gen d_marriage=leave if mig_why==3 
					replace d_marriage=0 if d_marriage==.

					* Women: No marriage at 1998
					gen group_age1=(age>=15 & age<=25)
					gen  group_age2=(age>=15 & age<=35)
					gen  group_age3=(age>=15 & age<=45)

* --- --- --- --- --- --- --- --- --- 
* TABLE V
* Marriage Market and Civil War - Individual  (OK))
* --- --- --- --- --- --- --- --- ---

					* Individual Analysis
					cap drop province_trend
					bys province year: gen province_trend=_n

					xtset id_person year
					eststo clear


					* BASELINE RESULTS 
						* Set of variables for the analysis

					local j=1
					forvalue i=1/3 {

						* Exposure
					qui eststo: xtreg d_marriage $exposure  i.year province_trend if group_age`i'==1 , cluster(reczd) fe 
					

						* Intensity 
					qui eststo: xtreg d_marriage $intensity  i.year province_trend if group_age`i'==1 , cluster(reczd) fe  
	
						}

						* Export estout (To check)
					esttab using "$result_table/Table_5.csv", star(* 0.10 ** 0.05 *** 0.01) replace nomtitles brackets label se(%9.3f) b(%9.3f) fragment keep($exposure $intensity)


* --- --- --- --- --- --- --- --- --- 
* TABLE VI
* Marriage Market and Civil War - Household  (OK))
* --- --- --- --- --- --- --- --- ---

					* Sample Household Analysis
					keep if age>=15 & age<=45
					bys id_hh year:egen sum_marrige=sum(d_marriage)
					bys id_hh year: gen d_hh_marriage=(sum_marrige!=0)

					drop hh
					cap bys id_hh year: gen hh=_n					
					keep if hh==1
					xtset id_hh year
					cap drop province_trend
					bys province year: gen province_trend=_n


					eststo clear
					local i=1
					foreach j in  $tables_hh {
					qui eststo: xtreg d_hh_marriage `j' i.year province_trend , cluster(reczd) fe
					}

					* Export estout (To check)
					esttab using "$result_table/Table_6.csv", star(* 0.10 ** 0.05 *** 0.01) replace nomtitles brackets label se(%9.3f) b(%9.3f) fragment keep( $tables_hh)

*************************************
*** Return Sample (Tables VII to VIII)
*** NON-MARRIAGE MIGRATION 
*************************************

	* Sample (permanent type_people==1 - Transitory  type_people==2 )
 	cap restore
 	preserve
 	keep if type_people==1|type_people==2
 	variables

* --- --- --- --- --- --- --- --- --- 
* TABLE VII (NEW)
* Returning Home and Civil War
* --- --- --- --- --- --- --- --- ---

 	* Gen Province time trend
		xtset id_person year
		bys province year: gen province_trend=_n
	
 	* Dependent variable

 		* Delete years who is at home
 		drop if mig_when>year & type_people==1
 		drop if temp_departure>year & type_people==2

 		gen d_return=(temp_return<=year)

 		* BASELINE RESULTS 
		* Set of variables for the analysis

		eststo clear
		* Column I: Individual Approach

					* a. Exposure 
						qui eststo: xtreg d_return $exposure  i.year province_trend, cluster(reczd) fe 
		
					* b. Intensity 
						qui eststo:qui xtreg d_return $intensity  i.year province_trend, cluster(reczd) fe 

		* Column II: Household Approach - Village exposure 

					* Building variables
							bys id_hh year:egen sum_return=sum(d_return)
							bys id_hh year: gen d_hh_return=(sum_return!=0)
							drop hh
							cap bys id_hh year: gen hh=_n							
							keep if hh==1
							xtset id_hh year
							cap drop province_trend
							bys province year: gen province_trend=_n

					* a. Exposure 
						qui eststo: xtreg d_hh_return $exposure  i.year province_trend, cluster(reczd) fe 
				
					* b. Intensity 
						qui eststo: xtreg d_hh_return $intensity  i.year province_trend, cluster(reczd) fe 


		* Column III-IV: Household Approach - Household exposure

				* Index Agricultural losses
						qui eststo: xtreg d_hh_return index_agri  i.year province_trend, cluster(reczd) fe 

				* Index Assets losses

						qui eststo: xtreg d_hh_return index_asset  i.year province_trend, cluster(reczd) fe 

		* Exporting Results

					esttab using "$result_table/Table_7.csv", star(* 0.10 ** 0.05 *** 0.01) replace nomtitles brackets label se(%9.3f) b(%9.3f) fragment keep( $exposure $intensity index_agri index_asset)

