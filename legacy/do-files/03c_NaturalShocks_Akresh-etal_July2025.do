*--------------------------------------------*
*---- Civil War and Household Composition ---*
*------ Akresh, Muñoz and Verwimp (2025) ----*
*------ 	 TABLES INDIVIDUAL  		 ----*
*------ 	  July 2, 2025  		     ----*
*--------------------------------------------*
*--------------------------------------------*

*-------------------------------------
* We include the data preliminaries 
* --- --- --- --- --- --- --- --- --- 
  
	run "$path_work/do-files/00_DataPreliminaries_Akresh-etal_2025.do"
	global results "$path_results/Akresh_etal_20250708_natural_shocks.xlsx" 
  
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
		
		*  PCA
		merge m:1 id_hh year using "$path_work/data/job/pca.dta", nogen keep(3)

* --- --- --- --- --- ---- ---- ----
		
		program define colname, rclass
			syntax, COL(integer)

			local abc = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

			* Si está entre A-Z
			if `col' <= 26 {
				local result = substr("`abc'", `col', 1)
			}
			else {
				local n1 = int((`col' - 1)/26)
				local n2 = mod(`col' - 1, 26) + 1
				local c1 = substr("`abc'", `n1', 1)
				local c2 = substr("`abc'", `n2', 1)
				local result = "`c1'`c2'"
			}

			return local name "`result'"
		end

* --- --- --- --- --- --- --- --- --- 
* Set of Variables
* --- --- --- --- --- --- --- --- --- 

		*  Variables to interact
		global base_vars "d_violence deathwounded_100 sk_vl_rob_land sk_vl_rob_product sk_vl_rob_money sk_vl_rob_goods sk_vl_rob_destruction pca_agri pca_asset pca_all"
		global natural_vars "pca_weather pca_natural pca_natural_all"
		
		
* --- --- --- --- --- ---- ---- ----
* TABLE I. Individual level
* --- --- --- --- --- --- --- --- ---
		
		*  Variables to interact
		global base_vars "d_violence deathwounded_100 sk_vl_rob_land sk_vl_rob_product sk_vl_rob_money sk_vl_rob_goods sk_vl_rob_destruction pca_agri pca_asset pca_all"
		global natural_vars "pca_weather pca_natural pca_natural_all"
		
		** Run regressions and store
		eststo clear
		local count = 1
		foreach z in $natural_vars {
			foreach x in $base_vars {
			qui xtreg leave `x' `z' i.year province_trend, fe cluster(reczd)
			eststo model_`count'
			qui summarize leave if e(sample)
			qui estadd scalar depmean = r(mean)
			local ++count
			}
		}
		
		* Set sheet
		putexcel set "$results", sheet("Table 1") modify
		
		local col = 3   
		local row = 5   
		local row_pca_start = 26
		local row_s = 32 
		
		forvalues i = 1/30 {
			
			* --- Restore current model ---
			est restore model_`i'
			
			* Identify variables
			local x = e(cmdline)
			foreach v in $base_vars {
				if strpos("`x'", "`v'") local vvar = "`v'"
			}
			foreach z in $natural_vars {
				if strpos("`x'", "`z'") local zvar = "`z'"
			}
			
			* --- Extract estimates ---
			scalar depm = e(depmean)
			scalar obs  = e(N)
			scalar bv = _b[`vvar']
			scalar se_v = _se[`vvar']
			scalar p_v = 2*ttail(e(df_r), abs(bv/se_v))
			local sv = ""
			if p_v < .01 local sv = "***"
			else if p_v < .05 local sv = "**"
			else if p_v < .10 local sv= "*"
			
			scalar bz = _b[`zvar']
			scalar sez = _se[`zvar']
			scalar p_z = 2*ttail(e(df_r), abs(bz/sez))
			local sz = ""
			if p_z < .01 local sz = "***"
			else if p_z < .05 local sz = "**"
			else if p_z < .10 local sz = "*"
			
			* --- Format values ---
			local bvfmt = string(bv, "%9.3f")
			local sevfmt = string(se_v, "%9.3f")
			local bzfmt = string(bz, "%9.3f")
			local sezfmt = string(sez, "%9.3f")
			local depm    = string(depm, "%9.3f")  
			local obs     = string(obs, "%9.0f")  
		
			* --- Export coefficient and standard error with stars ---
			colname, col(`col')
			local colname = r(name)

			putexcel `colname'`row' = ("`bvfmt'`sv'")
			putexcel `colname'`=`row'+1' = ("[`sevfmt']")

			if inlist(`i', 11, 21){
				local row_pca_start = `row_pca_start' + 2
			}

			local row_z = `row_pca_start'
			putexcel `colname'`row_z' = ("`bzfmt'`sz'")
			putexcel `colname'`=`row_z'+1' = ("[`sezfmt']")

			* --- Export regression statistics below the table ---
			putexcel `colname'`row_s' = `obs', overwrite italic
			local row_s1 = `row_s' + 1
			putexcel `colname'`row_s1' = `depm', overwrite italic

			* --- Update row and column
			if inlist(`i', 10, 20) {
				local row = 5	
			} 
			else if  inlist(`i', 2, 12, 22){
				local row = `row' + 3
			} 
			else {
				local row = `row' + 2
			}

			local col = `col' + 1

		}
		
		* Write variable labels
		local row_lbl = 5
		foreach v of varlist $base_vars {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
			if "`v'" == "deathwounded_100" {
				local row_lbl = `row_lbl' + 3
			}
			else {
				local row_lbl = `row_lbl' + 2
			}
		}
		local row_lbl = 26
		foreach v of varlist $natural_vars {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
			local row_lbl = `row_lbl' + 2
		}
		
		* --- Formatting: Fonts, headers and panels ---
		
		* Font sizes
		putexcel B2:AF36, font("Times New Roman", 12)
		putexcel B37:AF37, font("Times New Roman", 10)
		
		* Alignment
		putexcel C3:AF36, hcenter vcenter
		putexcel B4:B37, vcenter
		
		* --- Headers ---
		putexcel B2:AF2 = "Table 1. Baseline results. Armed Conflict and Non-Marital Migration, Individual-level Analysis", merge hcenter border(bottom)
		putexcel B3 = "Dependent Variable: Migration outside household in a given year (yes=1)", txtwrap hcenter vcenter
		putexcel B3:AF3, border(bottom, double)

		* --- Regression headers ---
		forvalues i = 1/30 {
			local j = `i' + 2      
			colname, col(`j')          
			local cname = r(name)
			
			putexcel `cname'3 = "(`i')"
		}

		* Column subtitles
		putexcel B4 = "Conflict exposure, Village level", italic underline
		putexcel B9 = "Conflict exposure, Household level", italic underline
		
		* --- Summary stats labels ---
		putexcel B9:AF9, border(top)
		putexcel B32:AF32, border(top)
		putexcel B32 = "Observations", italic
		putexcel B33 = "Mean Dependent Variable", italic
		putexcel B34 = "Household Fixed Effect", italic
		putexcel B35 = "Year Fixed Effect", italic
		putexcel B36 = "Province time-trend", italic
		
		forvalues i = 3/32 {
			colname, col(`i')
			local cname = r(name)
			
			putexcel `cname'34 = "Yes", italic
			putexcel `cname'35 = "Yes", italic
			putexcel `cname'36 = "Yes", italic
		}


		* --- Footnote ---
		putexcel B37:AF37 = ///
		"Notes - This table presents our baseline regression for non-marital migration at individual level. Robust standard errors, clustered at Village level. * p<0.10  ** p<0.05 *** p<0.01. The dependent variable, Migration outside of the household in a given year (yes=1) takes value one when a person migrates due to non-marital reasons in a given year. Sample includes all household members that either never migrate or migrate for non-marital reasons during 1998-2007. Violence in a given year (presence=1)   takes value one when the number of casualties in a given year is positive, 0 otherwise. Number of casualties in a given year includes the number of individuals killed or wounded in a given year, divided by 100 people. Index of Asset Related Losses refers - PCA -  refers to the first component from a Principal Component Analysis for Theft of money (yes=1), Theft or destruction of goods (yes=1), and Destruction of house (yes=1)  for a household in a given year.  Data Source: 2007 Burundi Priority Panel Survey.", ///
		merge txtwrap border(top)

		* --- Format with xl() ---
		mata
			b = xl()
			b.load_book("$results")
			b.set_sheet("Table 1")
			// Remove gridlines and set background white
			b.set_sheet_gridlines("Table 1", "off")
			// Column widths
			b.set_column_width(2,2,70)
			b.set_column_width(3,33,14)
			// Row heights
			b.set_row_height(3, 3, 50)
			b.set_row_height(4, 4, 25)
			b.set_row_height(9, 9, 25)
			b.set_row_height(37, 37, 30)
			b.close_book()
		end
		
* --- --- --- --- --- --- --- --- --- 
* TABLE II. Individual level with lags
* --- --- --- --- --- --- --- --- ---
		
		* Generate lags
		* Make sure panel is set
		xtset id_person year
		
		* List of variables for which we want to generate lags
		local basevars ///
		d_violence deathwounded_100 ///
		sk_vl_rob_land sk_vl_rob_product sk_vl_rob_money sk_vl_rob_goods sk_vl_rob_destruction ///
		pca_agri pca_asset pca_all pca_weather pca_natural pca_natural_all

		* Loop to generate lagged variables
		foreach var of local basevars {
			cap drop lag_`var'
			gen lag_`var' = L1.`var'
		}
		** Run regressions and store
		eststo clear
		local count = 1
		foreach z in $natural_vars {
			foreach x in $base_vars {
			qui xtreg leave `x' `z' lag_`x' lag_`z' i.year province_trend, fe cluster(reczd)
			eststo model_`count'
			qui summarize leave if e(sample)
			qui estadd scalar depmean = r(mean)
			local ++count
			}
		}
		
		* Set sheet
		putexcel set "$results", sheet("Table 2") modify
		
		local col = 3   
		local row = 5   
		local row_pca_start = 46
		local row_s = 58
		
		forvalues i = 1/30 {
			
			* --- Restore current model ---
			est restore model_`i'
			
			* Identify variables
			local x = e(cmdline)
			foreach v in $base_vars {
				if strpos("`x'", "`v'") local vvar = "`v'"
			}
			foreach z in $natural_vars {
				if strpos("`x'", "`z'") local zvar = "`z'"
			}
			
			local lag_vvar = "lag_`vvar'"
			local lag_zvar = "lag_`zvar'"
			
			* --- Extract estimates ---
			scalar depm = e(depmean)
			scalar obs  = e(N)
			
			scalar bv = _b[`vvar']
			scalar se_v = _se[`vvar']
			scalar p_v = 2*ttail(e(df_r), abs(bv/se_v))
			local sv = ""
			if p_v < .01 local sv = "***"
			else if p_v < .05 local sv = "**"
			else if p_v < .10 local sv= "*"
			
			scalar blagv = _b[`lag_vvar']
			scalar se_lagv = _se[`lag_vvar']
			scalar p_lagv = 2*ttail(e(df_r), abs(blagv/se_lagv))
			local slagv = ""
			if p_lagv < .01 local slagv = "***"
			else if p_lagv < .05 local slagv = "**"
			else if p_lagv < .10 local slagv= "*"
			
			scalar bz = _b[`zvar']
			scalar sez = _se[`zvar']
			scalar p_z = 2*ttail(e(df_r), abs(bz/sez))
			local sz = ""
			if p_z < .01 local sz = "***"
			else if p_z < .05 local sz = "**"
			else if p_z < .10 local sz = "*"
			
			scalar blagz = _b[`lag_zvar']
			scalar selagz = _se[`lag_zvar']
			scalar p_lagz = 2*ttail(e(df_r), abs(blagz/selagz))
			local slagz = ""
			if p_lagz < .01 local slagz = "***"
			else if p_lagz < .05 local slagz = "**"
			else if p_lagz < .10 local slagz = "*"
			
			* --- Format values ---
			local bvfmt = string(bv, "%9.3f")
			local sevfmt = string(se_v, "%9.3f")
			local blagvfmt = string(blagv, "%9.3f")
			local selagvfmt = string(se_lagv, "%9.3f")
			local bzfmt = string(bz, "%9.3f")
			local sezfmt = string(sez, "%9.3f")
			local blagzfmt = string(blagz, "%9.3f")
			local selagzfmt = string(selagz, "%9.3f")
			local depm    = string(depm, "%9.3f")  
			local obs     = string(obs, "%9.0f")  
		
			* --- Export coefficient and standard error with stars ---
			colname, col(`col')
			local colname = r(name)

			putexcel `colname'`row' = ("`bvfmt'`sv'")
			putexcel `colname'`=`row'+1' = ("[`sevfmt']")
			putexcel `colname'`=`row'+2' = ("`blagvfmt'`slagv'")
			putexcel `colname'`=`row'+3' = ("[`selagvfmt']")

			if inlist(`i', 11, 21){
				local row_pca_start = `row_pca_start' + 4
			}

			local row_z = `row_pca_start'
			putexcel `colname'`row_z' = ("`bzfmt'`sz'")
			putexcel `colname'`=`row_z'+1' = ("[`sezfmt']")
			putexcel `colname'`=`row_z'+2' = ("`blagzfmt'`slagz'")
			putexcel `colname'`=`row_z'+3' = ("[`selagzfmt']")
			

			* --- Export regression statistics below the table ---
			putexcel `colname'`row_s' = `obs', overwrite italic
			local row_s1 = `row_s' + 1
			putexcel `colname'`row_s1' = `depm', overwrite italic

			* --- Update row and column
			if inlist(`i', 10, 20) {
				local row = 5	
			} 
			else if  inlist(`i', 2, 12, 22){
				local row = `row' + 5
			} 
			else {
				local row = `row' + 4
			}

			local col = `col' + 1

		}
		
		* Write variable labels
		local row_lbl = 5
		foreach v of varlist $base_vars {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
			local row_lbl = `row_lbl' + 2
			putexcel B`row_lbl' = "Lag `lbl'"
			if "`v'" == "deathwounded_100" {
				local row_lbl = `row_lbl' + 3
			}
			else {
				local row_lbl = `row_lbl' + 2
			}
		}
		local row_lbl = 46
		foreach v of varlist $natural_vars {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
			local row_lbl = `row_lbl' + 2
			putexcel B`row_lbl' = "Lag `lbl'"
			local row_lbl = `row_lbl' + 2
		}
		
		* --- Formatting: Fonts, headers and panels ---
		
		* Font sizes
		putexcel B2:AF62, font("Times New Roman", 12)
		putexcel B63:AF63, font("Times New Roman", 10)
		
		* Alignment
		putexcel C3:AF62, hcenter vcenter
		putexcel B4:B63, vcenter
		
		* --- Headers ---
		putexcel B2:AF2 = "Table 2. Armed Conflict and Non-Marital Migration using lags, Individual-level Analysis", merge hcenter border(bottom)
		putexcel B3 = "Dependent Variable: Migration outside household in a given year (yes=1)", txtwrap hcenter vcenter
		putexcel B3:AF3, border(bottom, double)

		* --- Regression headers ---
		forvalues i = 1/30 {
			local j = `i' + 2      
			colname, col(`j')          
			local cname = r(name)
			
			putexcel `cname'3 = "(`i')"
		}
		
		* Column subtitles
		putexcel B4 = "Conflict exposure, Village level", italic underline
		putexcel B13 = "Conflict exposure, Household level", italic underline
		
		* --- Summary stats labels ---
		putexcel B13:AF13, border(top)
		putexcel B58:AF58, border(top)
		putexcel B58 = "Observations", italic
		putexcel B59 = "Mean Dependent Variable", italic
		putexcel B60 = "Individual Fixed Effect", italic
		putexcel B61 = "Year Fixed Effect", italic
		putexcel B62 = "Province time-trend", italic
		
		forvalues i = 3/32 {
			colname, col(`i')
			local cname = r(name)
			
			putexcel `cname'60 = "Yes", italic
			putexcel `cname'61 = "Yes", italic
			putexcel `cname'62 = "Yes", italic
		}


		* --- Footnote ---
		putexcel B63:AF63 = ///
		"Notes - This table presents our baseline regression for non-marital migration at individual level. Robust standard errors, clustered at Village level. * p<0.10  ** p<0.05 *** p<0.01. The dependent variable, Migration outside of the household in a given year (yes=1) takes value one when a person migrates due to non-marital reasons in a given year. Sample includes all household members that either never migrate or migrate for non-marital reasons during 1998-2007. Violence in a given year (presence=1)   takes value one when the number of casualties in a given year is positive, 0 otherwise. Number of casualties in a given year includes the number of individuals killed or wounded in a given year, divided by 100 people. Index of Asset Related Losses refers - PCA -  refers to the first component from a Principal Component Analysis for Theft of money (yes=1), Theft or destruction of goods (yes=1), and Destruction of house (yes=1)  for a household in a given year.  Data Source: 2007 Burundi Priority Panel Survey. Data Source: 2007 Burundi Priority Panel Survey.", ///
		merge txtwrap border(top)

		* --- Format with xl() ---
		mata
			b = xl()
			b.load_book("$results")
			b.set_sheet("Table 2")
			// Remove gridlines and set background white
			b.set_sheet_gridlines("Table 2", "off")
			// Column widths
			b.set_column_width(2,2,70)
			b.set_column_width(3,33,14)
			// Row heights
			b.set_row_height(3, 3, 50)
			b.set_row_height(4, 4, 25)
			b.set_row_height(13, 13, 25)
			b.set_row_height(63, 63, 30)
			b.close_book()
		end
		
		
* --- --- --- --- --- --- --- --- --- --
* TABLE III. Household level 
* --- --- --- --- --- --- --- --- --- ---

	*** Household level ***
	keep if hh==1
	xtset id_hh year
		
		** Run regressions and store
		eststo clear
		local count = 1
		foreach z in $natural_vars {
			foreach x in $base_vars {
			qui xtreg d_leave_hh `x' `z' i.year province_trend, fe cluster(reczd)
			eststo model_`count'
			qui summarize d_leave_hh if e(sample)
			qui estadd scalar depmean = r(mean)
			local ++count
			}
		}
		
		* Set sheet
		putexcel set "$results", sheet("Table 3") modify
		
		local col = 3   
		local row = 5   
		local row_pca_start = 26
		local row_s = 32 
		
		forvalues i = 1/30 {
			
			* --- Restore current model ---
			est restore model_`i'
			
			* Identify variables
			local x = e(cmdline)
			foreach v in $base_vars {
				if strpos("`x'", "`v'") local vvar = "`v'"
			}
			foreach z in $natural_vars {
				if strpos("`x'", "`z'") local zvar = "`z'"
			}
			
			* --- Extract estimates ---
			scalar depm = e(depmean)
			scalar obs  = e(N)
			scalar bv = _b[`vvar']
			scalar se_v = _se[`vvar']
			scalar p_v = 2*ttail(e(df_r), abs(bv/se_v))
			local sv = ""
			if p_v < .01 local sv = "***"
			else if p_v < .05 local sv = "**"
			else if p_v < .10 local sv= "*"
			
			scalar bz = _b[`zvar']
			scalar sez = _se[`zvar']
			scalar p_z = 2*ttail(e(df_r), abs(bz/sez))
			local sz = ""
			if p_z < .01 local sz = "***"
			else if p_z < .05 local sz = "**"
			else if p_z < .10 local sz = "*"
			
			* --- Format values ---
			local bvfmt = string(bv, "%9.3f")
			local sevfmt = string(se_v, "%9.3f")
			local bzfmt = string(bz, "%9.3f")
			local sezfmt = string(sez, "%9.3f")
			local depm    = string(depm, "%9.3f")  
			local obs     = string(obs, "%9.0f")  
		
			* --- Export coefficient and standard error with stars ---
			colname, col(`col')
			local colname = r(name)

			putexcel `colname'`row' = ("`bvfmt'`sv'")
			putexcel `colname'`=`row'+1' = ("[`sevfmt']")

			if inlist(`i', 11, 21){
				local row_pca_start = `row_pca_start' + 2
			}

			local row_z = `row_pca_start'
			putexcel `colname'`row_z' = ("`bzfmt'`sz'")
			putexcel `colname'`=`row_z'+1' = ("[`sezfmt']")

			* --- Export regression statistics below the table ---
			putexcel `colname'`row_s' = `obs', overwrite italic
			local row_s1 = `row_s' + 1
			putexcel `colname'`row_s1' = `depm', overwrite italic

			* --- Update row and column
			if inlist(`i', 10, 20) {
				local row = 5	
			} 
			else if  inlist(`i', 2, 12, 22){
				local row = `row' + 3
			} 
			else {
				local row = `row' + 2
			}

			local col = `col' + 1

		}
		
		* Write variable labels
		local row_lbl = 5
		foreach v of varlist $base_vars {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
			if "`v'" == "deathwounded_100" {
				local row_lbl = `row_lbl' + 3
			}
			else {
				local row_lbl = `row_lbl' + 2
			}
		}
		local row_lbl = 26
		foreach v of varlist $natural_vars {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
			local row_lbl = `row_lbl' + 2
		}
		
		* --- Formatting: Fonts, headers and panels ---
		
		* Font sizes
		putexcel B2:AF36, font("Times New Roman", 12)
		putexcel B37:AF37, font("Times New Roman", 10)
		
		* Alignment
		putexcel C3:AF36, hcenter vcenter
		putexcel B4:B37, vcenter
		
		* --- Headers ---
		putexcel B2:AF2 = "Table 3. Baseline results. Armed Conflict and Non-Marital Migration, Household-level Analysis", merge hcenter border(bottom)
		putexcel B3 = "Dependent Variable: At least one household member migrates outside household in a given year (yes=1)", txtwrap hcenter vcenter
		putexcel B3:AF3, border(bottom, double)

		* --- Regression headers ---
		forvalues i = 1/30 {
			local j = `i' + 2      
			colname, col(`j')          
			local cname = r(name)
			
			putexcel `cname'3 = "(`i')"
		}

		* Column subtitles
		putexcel B4 = "Conflict exposure, Village level", italic underline
		putexcel B9 = "Conflict exposure, Household level", italic underline
		
		* --- Summary stats labels ---
		putexcel B9:AF9, border(top)
		putexcel B32:AF32, border(top)
		putexcel B32 = "Observations", italic
		putexcel B33 = "Mean Dependent Variable", italic
		putexcel B34 = "Household Fixed Effect", italic
		putexcel B35 = "Year Fixed Effect", italic
		putexcel B36 = "Province time-trend", italic
		
		forvalues i = 3/32 {
			colname, col(`i')
			local cname = r(name)
			
			putexcel `cname'34 = "Yes", italic
			putexcel `cname'35 = "Yes", italic
			putexcel `cname'36 = "Yes", italic
		}


		* --- Footnote ---
		putexcel B37:AF37 = ///
		"Notes - This table presents our baseline regression for non-marital migration at household level. Robust standard errors, clustered at Village level. * p<0.10  ** p<0.05 *** p<0.01. The dependent variable, Migration outside of the household in a given year (yes=1) takes value one when a person migrates due to non-marital reasons in a given year. Sample includes all household members that either never migrate or migrate for non-marital reasons during 1998-2007. Violence in a given year (presence=1)   takes value one when the number of casualties in a given year is positive, 0 otherwise. Number of casualties in a given year includes the number of individuals killed or wounded in a given year, divided by 100 people. Index of Asset Related Losses refers - PCA -  refers to the first component from a Principal Component Analysis for Theft of money (yes=1), Theft or destruction of goods (yes=1), and Destruction of house (yes=1)  for a household in a given year.  Data Source: 2007 Burundi Priority Panel Survey.", ///
		merge txtwrap border(top)

		* --- Format with xl() ---
		mata
			b = xl()
			b.load_book("$results")
			b.set_sheet("Table 3")
			// Remove gridlines and set background white
			b.set_sheet_gridlines("Table 3", "off")
			// Column widths
			b.set_column_width(2,2,70)
			b.set_column_width(3,33,14)
			// Row heights
			b.set_row_height(3, 3, 50)
			b.set_row_height(4, 4, 25)
			b.set_row_height(9, 9, 25)
			b.set_row_height(37, 37, 30)
			b.close_book()
		end
		
		
* --- --- --- --- --- --- --- --- --- --
* TABLE IV. Household level with lags
* --- --- --- --- --- --- --- --- --- ---

		* Generate lags
		* Make sure panel is set
		xtset id_hh year
		
		* List of variables for which we want to generate lags
		local basevars ///
		d_violence deathwounded_100 ///
		sk_vl_rob_land sk_vl_rob_product sk_vl_rob_money sk_vl_rob_goods sk_vl_rob_destruction ///
		pca_agri pca_asset pca_all pca_weather pca_natural pca_natural_all

		* Loop to generate lagged variables
		foreach var of local basevars {
			cap drop lag_`var'
			gen lag_`var' = L1.`var'
		}
		** Run regressions and store
		eststo clear
		local count = 1
		foreach z in $natural_vars {
			foreach x in $base_vars {
			qui xtreg d_leave_hh `x' `z' lag_`x' lag_`z' i.year province_trend, fe cluster(reczd)
			eststo model_`count'
			qui summarize d_leave_hh if e(sample)
			qui estadd scalar depmean = r(mean)
			local ++count
			}
		}
		
		* Set sheet
		putexcel set "$results", sheet("Table 4") modify
		
		local col = 3   
		local row = 5   
		local row_pca_start = 46
		local row_s = 58
		
		forvalues i = 1/30 {
			
			* --- Restore current model ---
			est restore model_`i'
			
			* Identify variables
			local x = e(cmdline)
			foreach v in $base_vars {
				if strpos("`x'", "`v'") local vvar = "`v'"
			}
			foreach z in $natural_vars {
				if strpos("`x'", "`z'") local zvar = "`z'"
			}
			
			local lag_vvar = "lag_`vvar'"
			local lag_zvar = "lag_`zvar'"
			
			* --- Extract estimates ---
			scalar depm = e(depmean)
			scalar obs  = e(N)
			
			scalar bv = _b[`vvar']
			scalar se_v = _se[`vvar']
			scalar p_v = 2*ttail(e(df_r), abs(bv/se_v))
			local sv = ""
			if p_v < .01 local sv = "***"
			else if p_v < .05 local sv = "**"
			else if p_v < .10 local sv= "*"
			
			scalar blagv = _b[`lag_vvar']
			scalar se_lagv = _se[`lag_vvar']
			scalar p_lagv = 2*ttail(e(df_r), abs(blagv/se_lagv))
			local slagv = ""
			if p_lagv < .01 local slagv = "***"
			else if p_lagv < .05 local slagv = "**"
			else if p_lagv < .10 local slagv= "*"
			
			scalar bz = _b[`zvar']
			scalar sez = _se[`zvar']
			scalar p_z = 2*ttail(e(df_r), abs(bz/sez))
			local sz = ""
			if p_z < .01 local sz = "***"
			else if p_z < .05 local sz = "**"
			else if p_z < .10 local sz = "*"
			
			scalar blagz = _b[`lag_zvar']
			scalar selagz = _se[`lag_zvar']
			scalar p_lagz = 2*ttail(e(df_r), abs(blagz/selagz))
			local slagz = ""
			if p_lagz < .01 local slagz = "***"
			else if p_lagz < .05 local slagz = "**"
			else if p_lagz < .10 local slagz = "*"
			
			* --- Format values ---
			local bvfmt = string(bv, "%9.3f")
			local sevfmt = string(se_v, "%9.3f")
			local blagvfmt = string(blagv, "%9.3f")
			local selagvfmt = string(se_lagv, "%9.3f")
			local bzfmt = string(bz, "%9.3f")
			local sezfmt = string(sez, "%9.3f")
			local blagzfmt = string(blagz, "%9.3f")
			local selagzfmt = string(selagz, "%9.3f")
			local depm    = string(depm, "%9.3f")  
			local obs     = string(obs, "%9.0f")  
		
			* --- Export coefficient and standard error with stars ---
			colname, col(`col')
			local colname = r(name)

			putexcel `colname'`row' = ("`bvfmt'`sv'")
			putexcel `colname'`=`row'+1' = ("[`sevfmt']")
			putexcel `colname'`=`row'+2' = ("`blagvfmt'`slagv'")
			putexcel `colname'`=`row'+3' = ("[`selagvfmt']")

			if inlist(`i', 11, 21){
				local row_pca_start = `row_pca_start' + 4
			}

			local row_z = `row_pca_start'
			putexcel `colname'`row_z' = ("`bzfmt'`sz'")
			putexcel `colname'`=`row_z'+1' = ("[`sezfmt']")
			putexcel `colname'`=`row_z'+2' = ("`blagzfmt'`slagz'")
			putexcel `colname'`=`row_z'+3' = ("[`selagzfmt']")
			

			* --- Export regression statistics below the table ---
			putexcel `colname'`row_s' = `obs', overwrite italic
			local row_s1 = `row_s' + 1
			putexcel `colname'`row_s1' = `depm', overwrite italic

			* --- Update row and column
			if inlist(`i', 10, 20) {
				local row = 5	
			} 
			else if  inlist(`i', 2, 12, 22){
				local row = `row' + 5
			} 
			else {
				local row = `row' + 4
			}

			local col = `col' + 1

		}
		
		* Write variable labels
		local row_lbl = 5
		foreach v of varlist $base_vars {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
			local row_lbl = `row_lbl' + 2
			putexcel B`row_lbl' = "Lag `lbl'"
			if "`v'" == "deathwounded_100" {
				local row_lbl = `row_lbl' + 3
			}
			else {
				local row_lbl = `row_lbl' + 2
			}
		}
		local row_lbl = 46
		foreach v of varlist $natural_vars {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
			local row_lbl = `row_lbl' + 2
			putexcel B`row_lbl' = "Lag `lbl'"
			local row_lbl = `row_lbl' + 2
		}
		
		* --- Formatting: Fonts, headers and panels ---
		
		* Font sizes
		putexcel B2:AF62, font("Times New Roman", 12)
		putexcel B63:AF63, font("Times New Roman", 10)
		
		* Alignment
		putexcel C3:AF62, hcenter vcenter
		putexcel B4:B63, vcenter
		
		* --- Headers ---
		putexcel B2:AF2 = "Table 4. Armed Conflict and Non-Marital Migration using lags, Household-level Analysis", merge hcenter border(bottom)
		putexcel B3 = "Dependent Variable: At least one household member migrates outside household in a given year (yes=1)", txtwrap hcenter vcenter
		putexcel B3:AF3, border(bottom, double)

		* --- Regression headers ---
		forvalues i = 1/30 {
			local j = `i' + 2      
			colname, col(`j')          
			local cname = r(name)
			
			putexcel `cname'3 = "(`i')"
		}
		
		* Column subtitles
		putexcel B4 = "Conflict exposure, Village level", italic underline
		putexcel B13 = "Conflict exposure, Household level", italic underline
		
		* --- Summary stats labels ---
		putexcel B13:AF13, border(top)
		putexcel B58:AF58, border(top)
		putexcel B58 = "Observations", italic
		putexcel B59 = "Mean Dependent Variable", italic
		putexcel B60 = "Household Fixed Effect", italic
		putexcel B61 = "Year Fixed Effect", italic
		putexcel B62 = "Province time-trend", italic
		
		forvalues i = 3/32 {
			colname, col(`i')
			local cname = r(name)
			
			putexcel `cname'60 = "Yes", italic
			putexcel `cname'61 = "Yes", italic
			putexcel `cname'62 = "Yes", italic
		}


		* --- Footnote ---
		putexcel B63:AF63 = ///
		"Notes - This table presents our baseline regression for non-marital migration at household level. Robust standard errors, clustered at Village level. * p<0.10  ** p<0.05 *** p<0.01. The dependent variable, Migration outside of the household in a given year (yes=1) takes value one when a person migrates due to non-marital reasons in a given year. Sample includes all household members that either never migrate or migrate for non-marital reasons during 1998-2007. Violence in a given year (presence=1)   takes value one when the number of casualties in a given year is positive, 0 otherwise. Number of casualties in a given year includes the number of individuals killed or wounded in a given year, divided by 100 people. Index of Asset Related Losses refers - PCA -  refers to the first component from a Principal Component Analysis for Theft of money (yes=1), Theft or destruction of goods (yes=1), and Destruction of house (yes=1)  for a household in a given year.  Data Source: 2007 Burundi Priority Panel Survey. Data Source: 2007 Burundi Priority Panel Survey.", ///
		merge txtwrap border(top)

		* --- Format with xl() ---
		mata
			b = xl()
			b.load_book("$results")
			b.set_sheet("Table 4")
			// Remove gridlines and set background white
			b.set_sheet_gridlines("Table 4", "off")
			// Column widths
			b.set_column_width(2,2,70)
			b.set_column_width(3,33,14)
			// Row heights
			b.set_row_height(3, 3, 50)
			b.set_row_height(4, 4, 25)
			b.set_row_height(13, 13, 25)
			b.set_row_height(63, 63, 30)
			b.close_book()
		end
		
		