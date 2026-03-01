* --- --- --- --- --- --- --- --- --- 
* We include the data preliminaries 
* --- --- --- --- --- --- --- --- --- 
  
    global path_work "/Users/jmunozm1/Documents/GitHub/household_structure_burundi/"
	run "do-files/00_DataPreliminaries_Akresh-etal_2025.do"
	global results "out/Akresh_etal_20251112_otherschocks.xlsx" 
  
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
		global tables_hh d_violence deathwounded_100 sk_vl_rob_land sk_vl_rob_product sk_vl_rob_money sk_vl_rob_goods sk_vl_rob_destruction pca_agri pca_asset pca_all
		
*************************************
*** Baseline Sample
*** NON-MARRIAGE MIGRATION 
************************************* 
		
		keep if restr_7==1
		variables

		* Gen Province time trend
		xtset id_person year
		bys province year: gen province_trend=_n

		merge m:1 id_hh year using "$path_work/data/job/pca.dta", nogen
	
			
* -------------------------------------------------------------
* Expenditure
* ------------------------------------------------------------

		rename year jaar
		merge m:1 reczd numen numsplit pid07 jaar using "$path_work/data/origin/demofinal17.dta", keepusing(totexp_a98 TOTEXP_mae07 litm98) keep(1 3) nogen
		
		sum totexp_a98 if n_hh==1
		*Se tienen 500 observaciones de gasto y en total son 800 hogares
		
		sum TOTEXP_mae07 if n_hh==1
		*Se tienen 500 observaciones de gasto y en total son 800 hogares
		
		rename jaar year
		
		
*-------------------------------------------------------------
* Migration demographic (age and sex)
*-------------------------------------------------------------		
		replace leave = 0 if missing(leave)
		
		* Age
		gen leave_adult  = (leave == 1 & adult_18 == 1) 
		gen leave_child = (leave == 1 & adult_18 == 0) 
		* Sex
		gen leave_woman = (leave == 1 & sex == 1) 
		gen leave_man = (leave == 1 & sex == 0) 

* -----------------------------------------------------------
* Migration variables
* -----------------------------------------------------------

		local migration leave leave_adult leave_child leave_woman leave_man

		* Tamaño del hogar por año
		bys id_hh year: gen hh_size = _N

		egen woman_size = total(sex==1), by(id_hh year)
		egen man_size = total(sex==0), by(id_hh year)
		egen child_size = total(adult_18==0), by(id_hh year)
		egen adult_size = total(adult_18==1), by(id_hh year)
		
		* Tamaños máximos por hogar (invariantes por año)
		bys id_hh: egen max_child_size = max(child_size)
		bys id_hh: egen max_adult_size = max(adult_size)

		foreach v of local migration {
			* At least 1 person left the household in a GIVEN YEAR (varía por año)
			bys id_hh year: egen any_`v' = max(`v')
			
			* Number of members who left household in a given year
			bys id_hh year: egen total_`v'_year = total(`v')
			
			* Share of household members who left in a given year (varía por año)
			gen share_`v' = .
			if      inlist("`v'","leave")                    replace share_`v' = total_`v'_year/hh_size
			else if inlist("`v'","leave_adult","mig_adult")  replace share_`v' = total_`v'_year/adult_size
			else if inlist("`v'","leave_child","mig_child")  replace share_`v' = total_`v'_year/child_size
			else if inlist("`v'","leave_woman","mig_woman")  replace share_`v' = total_`v'_year/woman_size 
			else if inlist("`v'","leave_man","mig_man")      replace share_`v' = total_`v'_year/man_size 
			replace share_`v' = 0 if missing(share_`v')
		}


        global depvars "any_leave any_leave_adult any_leave_child any_leave_man any_leave_woman  share_leave share_leave_adult share_leave_child share_leave_man share_leave_woman"
       

        

* -----------------------------------------------------------
* Violence variables
* -----------------------------------------------------------
bys id_hh year: gen tag_hhy = _n==1

		replace d_violence = 0 if missing(d_violence)
		replace deathwounded_100 = 0 if missing(deathwounded_100)
		

		* Dummy presence of violence during 1998-2007 (yes=1)
		bys id_hh: egen any_violence = max(d_violence)
		* Number of years with presence of violence during 1998-2007
		bys id_hh: egen years_violence = total(cond(tag_hhy, d_violence, .))
		* Average of dead and wounded per year (by 100 people) 1998-2007
		bys id_hh: egen avg_deathwounded_100 = mean(cond(tag_hhy, deathwounded_100, .))

* -----------------------------------------------------------
* Shocks variables
* -----------------------------------------------------------
		local shocks sk_vl_rob_land sk_vl_rob_product sk_vl_rob_money sk_vl_rob_goods sk_vl_rob_destruction sk_jail sk_movi sk_att sk_kidnap sk_workforced sk_torture sk_contribution sk_nt_rain sk_nt_drought sk_nt_disease sk_nt_crop_bad sk_nt_destru_rain sk_nt_erosion  sk_ec_input_access sk_ec_input_price sk_ec_nonmarket sk_ec_output_price sk_ec_sell_land sk_ec_sell_other sk_ec_rec_help

		foreach v of local shocks {
			replace `v' = 0 if missing(`v')
		}

		foreach v of local shocks {
			* Shock (yes=1) for a household in 1998-07
			bys id_hh: egen any_`v' = max(`v')
			* Number of years that household had a shock
			bys id_hh: egen years_`v' = total(cond(tag_hhy, `v', .))
		}
		
* -----------------------------------------------------------
* PCA variables
* -----------------------------------------------------------

		local pcas pca_agri pca_asset pca_economic pca_coping pca_weather pca_natural pca_natural_all pca_all
		
		foreach x of local pcas {

			* PCA mean
			cap bys id_hh: egen `x'_mean = mean(cond(tag_hhy, `x', .))
			* Umbral = media muestral del promedio por hogar
			quietly summarize `x'_mean if n_hh == 1
			local cutoff_mean = r(mean)
			cap gen `x'_above_mean = (`x'_mean > `cutoff_mean') if `x'_mean < .
		}

* -------------------------------------------------------------
* Household Baseline Characteristics 1998
* ------------------------------------------------------------

		* Poverty status
		replace Poverty_status_98 = 0 if missing(Poverty_status_98)
		replace Poverty_status_07 = 0 if missing(Poverty_status_07)
		* Demographic characteristics
		gen head1998 = (year==1998 & pid07==1)
		* Sex
		bys id_hh: egen hh_head_female_1998 = max(cond(head1998, sex, .))
		replace hh_head_female_1998 = 0 if missing(hh_head_female_1998)
		* Age		
		bys id_hh: egen hh_head_age_1998 = max(cond(head1998, age, .))
		egen age_mean = mean(hh_head_age_1998)
		replace hh_head_age_1998 = age_mean if missing(hh_head_age_1998)
		* Livestock
		bys id_hh year: egen livestock_hhy = mean(livestock)
		bys id_hh: egen avg_livestock = mean(livestock_hhy)

* -------------------------------------------------------------
* Village controls
* ------------------------------------------------------------
		egen altitude_mean = mean(altitude_av__m_)
		replace altitude_av__m_ = altitude_mean if missing(altitude_av__m_)

		egen rainfall_mean = mean(rainfall_av__mm_)
		replace rainfall_av__mm_ = rainfall_mean if missing(rainfall_av__mm_)
		
		egen temp_mean = mean(temp_av)
		replace temp_av = temp_mean if missing(temp_av)
		

* --- --- --- --- --- --- --- --- --- 
* Set of Variables
* --- --- --- --- --- --- --- --- --- 

		global exposure "d_violence"
		global intensity "deathwounded_100"
		global tables "sk_vl_rob_land sk_vl_rob_product sk_vl_rob_money sk_vl_rob_goods sk_vl_rob_destruction sk_jail sk_movi sk_att sk_kidnap sk_workforced sk_torture sk_contribution sk_nt_rain sk_nt_drought sk_nt_disease sk_nt_crop_bad sk_nt_destru_rain sk_nt_erosion  sk_ec_input_access sk_ec_input_price sk_ec_nonmarket sk_ec_output_price sk_ec_sell_land sk_ec_sell_other sk_ec_rec_help pca_agri pca_asset pca_economic pca_coping pca_weather pca_natural pca_natural_all pca_all"
		
    foreach var in $tables {
			replace `var' = 0 if missing(`var')
			}

	* Apply labels to all variables
	run "do-files/labels.do"


* --- --- --- --- --- --- --- --- --- 
* TABLE I
* Summary Statistics 1997-2008
* --- --- --- --- --- --- --- --- --- 

        eststo clear
		* Individual-year level 
		estpost tabstat d_violence deathwounded_100 leave, stats(n mean sd) columns(statistics) 
		eststo ind_year
		
		* Individual level 
		estpost tabstat d_leave_ind if n_ind==1, stats(n mean sd) columns(statistics)  
		eststo ind_level

		* Household-year level 
		estpost tabstat d_violence deathwounded_100 d_leave_hh leave_hh $tables if hh==1, stats(n mean sd) columns(statistics)
		eststo hh_year

		* Household Level 
		estpost tabstat hh_d_violence hh_deathwounded leave_hh_t d_leave_hh_t $tables if n_hh==1, stats(n mean sd) columns(statistics)
		eststo hh_level
		
		* Export to CSV with labels
		esttab ind_year ind_level hh_year hh_level using "$path_results/table1_summary.csv", ///
			cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2))") ///
			label replace noobs plain
		


* --- --- --- --- --- --- --- --- --- 
* TABLE II - Individual - No interaction
* --- --- --- --- --- --- --- --- ---
	
		* --- Regressions - no violence
		
        
        eststo clear
		foreach j in $tables {
			eststo: xtreg leave `j' i.year province_trend, cluster(reczd) fe 
		}
		
		* Export to CSV with labels
		esttab using "$path_results/table2_individual_no_interaction.csv", ///
			drop(*.year province_trend) cells(b(fmt(3) star) se(fmt(3) par)) ///
			addnotes("Dependent Variable: Migration outside household in a given year (yes=1)" "Year fixed effects and province trend included") ///
			label replace plain
* --- --- --- --- --- --- --- --- --- 
* TABLE III - Household Level (Year-Varying Outcomes)
* --- --- --- --- --- --- --- --- ---	

        foreach d in $depvars {

        foreach m in "" $exposure $intensity {

		eststo clear
		
		foreach j in $tables {
			* Regresiones individuales a nivel hogar-año con FE
			eststo: xtreg `d' `m' `j' i.year province_trend, cluster(reczd) fe 
		}
		
		* Export to CSV with labels
		esttab using "$path_results/table3_`d'_`m'.csv", ///
			drop(*.year province_trend) cells(b(fmt(3) star) se(fmt(3) par)) ///
			addnotes("Dependent Variable: `d' (varies by year)" "Year fixed effects and province trend included" "Household-year level observations") ///
			label replace plain

        }

        }



