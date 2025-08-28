* --- --- --- --- --- --- --- --- --- 
* We include the data preliminaries 
* --- --- --- --- --- --- --- --- --- 
  
	run "do-files/00_DataPreliminaries_Akresh-etal_2025.do"
	global results "$path_results/Akresh_etal_20250708_household.xlsx" 
  
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
		qui include "$path_work/do-files/labels.do" 

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

		* Tamaño del hogar
		bys id_hh year: gen hh_size = _N

		egen woman_size = total(sex==1), by(id_hh year)
		egen man_size = total(sex==0), by(id_hh year)
		egen child_size = total(adult_18==0), by(id_hh year)
		egen adult_size = total(adult_18==1), by(id_hh year)
		bys id_hh: egen max_child_size = max(child_size)
		bys id_hh: egen max_adult_size = max(adult_size)

		foreach v of local migration {
			* At least 1 person left the household in a given year (yes=1)
			bys id_hh: egen any_`v' = max(`v')
			* Number of members who left household 1998-2007
			sort id_person year
			gen first_`v' = 0
			by id_person (year): replace first_`v' = `v'==1 & (`v'[_n-1]==0 | _n==1)
			bys id_hh year: egen total_`v'_year = total(first_`v')
			bys id_hh: egen total_`v' = total(first_`v')
			* Share of household members who left household 1998-2007
			gen share_`v' = .
			if      inlist("`v'","leave")                    replace share_`v' = total_`v'/hh_size
			else if inlist("`v'","leave_adult","mig_adult")  replace share_`v' = total_`v'/max_adult_size 
			else if inlist("`v'","leave_child","mig_child")  replace share_`v' = total_`v'/max_child_size
			else if inlist("`v'","leave_woman","mig_woman")  replace share_`v' = total_`v'/woman_size 
			else if inlist("`v'","leave_man","mig_man")      replace share_`v' = total_`v'/man_size 
			replace share_`v' = 0 if missing(share_`v')
		}

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
			bys id_hh: egen `x'_mean = mean(cond(tag_hhy, `x', .))
			* Umbral = media muestral del promedio por hogar
			quietly summarize `x'_mean if n_hh == 1
			local cutoff_mean = r(mean)
			gen `x'_above_mean = (`x'_mean > `cutoff_mean') if `x'_mean < .
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
		
* -------------------------------------------------------------
* Labels 
* ------------------------------------------------------------

	run "do-files/labels.do"

*-------------------------------------------------------------------
* Models
*------------------------------------------------------------------------
		keep if n_hh == 1
		
		global base_vars "any_violence years_violence avg_deathwounded_100 any_sk_vl_rob_land any_sk_vl_rob_product any_sk_vl_rob_money any_sk_vl_rob_goods any_sk_vl_rob_destruction any_sk_jail any_sk_movi any_sk_att any_sk_kidnap any_sk_workforced any_sk_torture any_sk_contribution any_sk_nt_rain any_sk_nt_drought any_sk_nt_disease  any_sk_nt_crop_bad any_sk_nt_destru_rain any_sk_nt_erosion any_sk_ec_input_access any_sk_ec_input_price any_sk_ec_nonmarket any_sk_ec_output_price any_sk_ec_sell_land any_sk_ec_sell_other any_sk_ec_rec_help years_sk_vl_rob_land years_sk_vl_rob_product years_sk_vl_rob_money years_sk_vl_rob_goods years_sk_vl_rob_destruction years_sk_jail years_sk_movi years_sk_att years_sk_kidnap years_sk_workforced years_sk_torture years_sk_contribution years_sk_nt_rain years_sk_nt_drought years_sk_nt_disease years_sk_nt_crop_bad years_sk_nt_destru_rain years_sk_nt_erosion  years_sk_ec_input_access years_sk_ec_input_price years_sk_ec_nonmarket years_sk_ec_output_price years_sk_ec_sell_land years_sk_ec_sell_other years_sk_ec_rec_help pca_agri_mean pca_asset_mean pca_economic_mean pca_coping_mean pca_weather_mean pca_natural_mean pca_natural_all_mean pca_all_mean"

				
		global controls "hh_head_female_1998 hh_head_age_1998 altitude_av__m_ rainfall_av__mm_ temp_av i.province"

				
		* General
global interactions "any_leave total_leave share_leave"

		* Limpia contenedores
		eststo clear
		estimates clear

		* Para títulos de columnas (modelo = combinación b × z)
		local mtitles

		* Loop por combinaciones b × z
		local k = 0
		foreach b of global base_vars {
			foreach z of global interactions {

				* Regresión con interacción y controles
				qui reg Poverty_status_07 Poverty_status_98 c.`b'##c.`z' $controls , vce(cluster reczd)
				qui su Poverty_status_07 if e(sample)
				qui estadd scalar ymean = r(mean)

				* Guarda el modelo
				local ++k
				eststo m`k'

				* Construye título de columna
				local mtitles `"`mtitles' "(`k')""'
			}
		}

		*---- Exporta solo lo principal (b, z, b#z) y sin controles ----*
		esttab m* using "${path_results}/results_welfare_all.html", ///
			replace                             ///
			keep(Poverty_status_98 $base_vars $interactions *#*)                           ///
			order(Poverty_status_98 $base_vars $interactions *#*) ///
			b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
			stats(N r2 ymean, labels("Obs." "R^2" "Media dep.")) ///
			mtitles(`mtitles') ///
			nonumbers ///
			label ///
			compress
	
		* Limpia contenedores
		eststo clear
		estimates clear

			* Adult
global interactions "any_leave_adult total_leave_adult share_leave_adult"


		* --- Limpia contenedor de estimaciones ---
		estimates clear
		collect clear
		local mtitles
		
		* --- Loop: todas las combinaciones base x interaction ---
		local k = 0
		foreach b of global base_vars {
			foreach z of global interactions {

				* Regresión con interacción y controles
				qui reg Poverty_status_07 Poverty_status_98 c.`b'##c.`z' $controls , vce(cluster reczd)
				qui su Poverty_status_07 if e(sample)
				qui estadd scalar ymean = r(mean)

				* Guarda el modelo
				local ++k
				eststo m`k'

				* Construye título de columna
				 local mtitles `"`mtitles' "(`k')""'
			}
		}
		
		*---- Exporta solo lo principal (b, z, b#z) y sin controles ----*
		esttab m* using "${path_results}/results_welfare_adult.html", ///
			replace                             ///
			keep(Poverty_status_98 $base_vars $interactions *#*)                           ///
			order(Poverty_status_98 $base_vars $interactions *#*) ///
			b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
			stats(N r2 ymean, labels("Obs." "R^2" "Media dep.")) ///
			mtitles(`mtitles') ///
			nonumbers ///
			label ///
			compress
			
		* Child
		
global interactions "any_leave_child total_leave_child share_leave_child"	
	
		* --- Limpia contenedor de estimaciones ---
		estimates clear
		collect clear
		local mtitles

		* --- Limpia contenedor de estimaciones ---
		estimates clear
		collect clear

		* --- Loop: todas las combinaciones base x interaction ---
		local k = 0
		foreach b of global base_vars {
			foreach z of global interactions {

				* Regresión con interacción y controles
				qui reg Poverty_status_07 Poverty_status_98 c.`b'##c.`z' $controls , vce(cluster reczd)
				qui su Poverty_status_07 if e(sample)
				qui estadd scalar ymean = r(mean)
		
				* Guarda el modelo
				local ++k
				eststo m`k'

				* Construye título de columna
				local mtitles `"`mtitles' "(`k')""'
			}
		}
		
		esttab m* using "${path_results}/results_welfare_child.html", ///
			replace                             ///
			keep(Poverty_status_98 $base_vars $interactions *#*)                           ///
			order(Poverty_status_98 $base_vars $interactions *#*) ///
			b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
			stats(N r2 ymean, labels("Obs." "R^2" "Media dep.")) ///
			mtitles(`mtitles') ///
			nonumbers ///
			label ///
			compress
			
			* Woman
global interactions "any_leave_woman total_leave_woman share_leave_woman"

	
		* --- Limpia contenedor de estimaciones ---
		estimates clear
		collect clear

		* --- Loop: todas las combinaciones base x interaction ---
		local k = 0
		foreach b of global base_vars {
			foreach z of global interactions {

				* Regresión con interacción y controles
				qui reg Poverty_status_07 Poverty_status_98 c.`b'##c.`z' $controls , vce(cluster reczd)
				qui su Poverty_status_07 if e(sample)
				qui estadd scalar ymean = r(mean)

				* Guarda el modelo
				local ++k
				eststo m`k'

				* Construye título de columna
				local mtitles `"`mtitles' "(`k')""'
			}
		}
		
		esttab m* using "${path_results}/results_welfare_woman.html", ///
			replace                             ///
			keep(Poverty_status_98 $base_vars $interactions *#*)                           ///
			order(Poverty_status_98 $base_vars $interactions *#*) ///
			b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
			stats(N r2 ymean, labels("Obs." "R^2" "Media dep.")) ///
			mtitles(`mtitles') ///
			nonumbers ///
			label ///
			compress
			
		
			* Man
global interactions "any_leave_man total_leave_man share_leave_man"

		* --- Limpia contenedor de estimaciones ---
		estimates clear
		collect clear

		* --- Loop: todas las combinaciones base x interaction ---
		local k = 0
		foreach b of global base_vars {
			foreach z of global interactions {

				* Regresión con interacción y controles
				qui reg Poverty_status_07 Poverty_status_98 c.`b'##c.`z' $controls , vce(cluster reczd)
				qui su Poverty_status_07 if e(sample)
				qui estadd scalar ymean = r(mean)

				* Guarda el modelo
				local ++k
				eststo m`k'

				* Construye título de columna
				local mtitles `"`mtitles' "(`k')""'
			}
		}
		
		esttab m* using "${path_results}/results_welfare_man.html", ///
			replace                             ///
			keep(Poverty_status_98 $base_vars $interactions *#*)                           ///
			order(Poverty_status_98 $base_vars $interactions *#*) ///
			b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
			stats(N r2 ymean, labels("Obs." "R^2" "Media dep.")) ///
			mtitles(`mtitles') ///
			nonumbers ///
			label ///
			compress