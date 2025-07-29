*--------------------------------------------*
*---- Civil War and Household Composition ---*
*------ Akresh, Muñoz and Verwimp (2025) ----*
*------ 	 TABLES WELFARE  		     ----*
*------ 	  July 1, 2025  		     ----*
*--------------------------------------------*
*--------------------------------------------*

* --- --- --- --- --- --- --- --- --- 
* We include the data preliminaries 
* --- --- --- --- --- --- --- --- --- 
  
	run "do-files/00_DataPreliminaries_Akresh-etal_2025.do"
	global results "$path_results/Akresh_etal_20250708_welfare_new.xlsx" 
  
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
		
		* PCA
		merge m:1 id_hh year using "$path_work/data/job/pca.dta", keep(3) nogen
		/*
		*Expenditure
		rename year jaar
		merge 1:1 reczd numen numsplit pid07 jaar using "$path_work/data/origin/demofinal17.dta", keepusing(totexp_a98 TOTEXP_mae07 litm98) keep(1 3) nogen
		*/
		
		* One household observation
		keep if n_hh==1
* --- --- --- --- --- --- --- --- --- 
* TABLE I
*--- --- --- --- --- --- --- --- --- --
		/*
		gen growth_exp = ln(TOTEXP_mae07 / totexp_a98)
		
		* Example
		reg growth_exp leave_hh_t ///
			sex_98 age_98 ///
			altitude_av__m_ rainfall_av__mm_ temp_av ///
			province_trend, vce(cluster reczd)
		*/
* --- --- --- --- --- --- --- --- --- 
* TABLE II
*--- --- --- --- --- --- --- --- --- --
		
		* Scape out of poverty
		gen scape_poverty = 0
		replace scape_poverty = 1 if Poverty_status_98 == 1 & Poverty_status_07 == 0
		
		keep if Poverty_status_98 == 1 
		
		* Variables
		global basevars "hh_d_violence v_s_violence hh_deathwounded_100 hh_sk_vl_rob_land hh_sk_vl_rob_product hh_sk_vl_rob_money hh_sk_vl_rob_goods hh_sk_vl_rob_destruction pca_agri_hh pca_asset_hh pca_all_hh pca_natural_all_hh"	
		
		* Run regressions and store
		eststo clear
		foreach j of global basevars {
			
			qui reg scape_poverty `j' i.province_trend, vce(cluster reczd)	
			quietly summarize scape_poverty if e(sample)
			qui estadd scalar depmean = r(mean)  
			eststo `j'  
		}

		*** Export results to Excel
		putexcel set "$results", sheet("Table 2") modify  
		
		local col = 3
		local row = 5
		local row_s = 30     

		foreach j of global basevars {

			* --- Restore current model ---
			est restore `j'

			* --- Extract estimates ---
			scalar b  = _b[`j']
			scalar se = _se[`j']
			scalar p  = 2*ttail(e(df_r), abs(b/se))
			scalar depm = e(depmean)
			scalar obs  = e(N)

			* --- Build stars for significance ---
			local stars ""
			if      (p < .01) local stars "***"
			else if (p < .05) local stars "**"
			else if (p < .10) local stars "*"

			* --- Format values ---
			local b_fmt   = string(b, "%9.3f")     // Coefficient
			local se_fmt  = string(se, "%9.3f")    // Standard error
			local depm    = string(depm, "%9.3f")  // Mean of dependent variable
			local obs     = string(obs, "%9.0f")   // Number of observations

			* --- Export coefficient with stars ---
			putexcel `=char(`col'+64)'`row' = ("`b_fmt'`stars'"), overwrite 

			* --- Export standard error in brackets (row below) ---
			local r1 = `row' + 1
			putexcel `=char(`col'+64)'`r1' = ("[`se_fmt']"), overwrite 

			* --- Export regression statistics below the table ---
			putexcel `=char(`col'+64)'`row_s' = `obs', overwrite italic
			local row_s1 = `row_s' + 1
			putexcel `=char(`col'+64)'`row_s1' = `depm', overwrite italic

			* --- Leave extra space after deathwounded_100 ---
			if "`j'" == "hh_deathwounded_100" {
				local row = `row' + 1
				putexcel B`row':L`row', border(bottom)
				local row = `row' + 2 
			} 
			else {
				local row = `row' + 2
			}
			
			local col = `col' + 1
		}

		* Write variable labels
		local row_lbl = 5
		foreach v of varlist $basevars {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"

			if "`v'" == "hh_deathwounded_100" {
				local row_lbl = `row_lbl' + 3
			}
			else {
				local row_lbl = `row_lbl' + 2
			}
		}
		
		* --- Formatting: Fonts, headers and panels ---
		
		* Font sizes
		putexcel B2:N32, font("Times New Roman", 12)
		putexcel B33:N33, font("Times New Roman", 10)
		
		* Alignment
		putexcel C3:N32, hcenter vcenter
		putexcel B4:B33, vcenter
		
		* --- Headers ---
		putexcel B2:L2 = "Table 2. Analysis of scape out of poverty between 1998  - 2007 (OLS), household-level information", merge hcenter border(bottom)
		putexcel B3 = "Dependent Variable: Scape out of poverty (poor in 1998 and non-poor 2007=1)", txtwrap hcenter vcenter
		putexcel B3:L3, border(bottom, double)

		* --- Regression headers ---
		forvalues i = 1/12 {
			putexcel `=char(`i'+66)'3 = "(`i')",
		}
		
		* Column subtitles
		putexcel B4 = "Conflict exposure, Village level", italic underline
		putexcel B11 = "Conflict exposure, Household level", italic underline
		
		* --- Summary stats labels ---
		putexcel B30:N30, border(top)
		putexcel B30 = "Observations", italic
		putexcel B31 = "Mean Dependent Variable", italic
		putexcel B32 = "Province time-trend", italic
		
		forvalues i = 3/14 {
			putexcel `=char(`i'+64)'32 = "Yes", italic

		}

		* --- Footnote ---
		putexcel B33:N33 = ///
		"Notes - This table presents the probit analysis of scape out of poverty between 1998 and 2007. Marginal effects reported. Robust standard error, clustered at Village level. * p<0.10  ** p<0.05 *** p<0.01. The dependent variable, Scape out of poverty (poor in 1998 and non-poor 2007=1), takes 1 when a poor household in 1998 became non-poor in 2007. Indexes  of Asset Related Losses refers - PCA -  refers to the first component from a Principal Component Analysis for Theft of money (yes=1), Theft or destruction of goods (yes=1), and Destruction of house (yes=1)  for a household in a given year. Data Source: 2007 Burundi Priority Panel Survey.", ///
		merge txtwrap border(top)

		* --- Format with xl() ---
		mata
			b = xl()
			b.load_book("$results")
			b.set_sheet("Table 2")
			// Remove gridlines and set background white
			b.set_sheet_gridlines("Table 2", "off")
			// Column widths
			b.set_column_width(2,2,60)
			b.set_column_width(3,14,14)
			// Row heights
			b.set_row_height(3, 3, 50)
			b.set_row_height(4, 4, 25)
			b.set_row_height(11, 11, 25)
			b.set_row_height(33, 33, 50)
			b.close_book()
		end

* --- --- --- --- --- --- --- --- --- 
* TABLE III
*--- --- --- --- --- --- --- --- --- --
			
		*Controls
		global controls "sex_98 age_98 altitude_av__m_ rainfall_av__mm_ temp_av i.province_trend"
		* Run regressions and store
		eststo clear
		foreach j of global basevars {
			
			qui reg scape_poverty `j' $controls i.province_trend, vce(cluster reczd)	
			quietly summarize scape_poverty if e(sample)
			qui estadd scalar depmean = r(mean)  
			eststo `j'  
		}

		*** Export results to Excel
		putexcel set "$results", sheet("Table 3") modify  
		
		local col = 3
		local row = 5
		local row_s = 30     

		local col = 3
		local row = 5
		local row_s = 30     

		foreach j of global basevars {

			* --- Restore current model ---
			est restore `j'

			* --- Extract estimates ---
			scalar b  = _b[`j']
			scalar se = _se[`j']
			scalar p  = 2*ttail(e(df_r), abs(b/se))
			scalar depm = e(depmean)
			scalar obs  = e(N)

			* --- Build stars for significance ---
			local stars ""
			if      (p < .01) local stars "***"
			else if (p < .05) local stars "**"
			else if (p < .10) local stars "*"

			* --- Format values ---
			local b_fmt   = string(b, "%9.3f")     // Coefficient
			local se_fmt  = string(se, "%9.3f")    // Standard error
			local depm    = string(depm, "%9.3f")  // Mean of dependent variable
			local obs     = string(obs, "%9.0f")   // Number of observations

			* --- Export coefficient with stars ---
			putexcel `=char(`col'+64)'`row' = ("`b_fmt'`stars'"), overwrite 

			* --- Export standard error in brackets (row below) ---
			local r1 = `row' + 1
			putexcel `=char(`col'+64)'`r1' = ("[`se_fmt']"), overwrite 

			* --- Export regression statistics below the table ---
			putexcel `=char(`col'+64)'`row_s' = `obs', overwrite italic
			local row_s1 = `row_s' + 1
			putexcel `=char(`col'+64)'`row_s1' = `depm', overwrite italic

			* --- Leave extra space after deathwounded_100 ---
			if "`j'" == "hh_deathwounded_100" {
				local row = `row' + 1
				putexcel B`row':L`row', border(bottom)
				local row = `row' + 2 
			} 
			else {
				local row = `row' + 2
			}
			
			local col = `col' + 1
		}

		* Write variable labels
		local row_lbl = 5
		foreach v of varlist $basevars {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"

			if "`v'" == "hh_deathwounded_100" {
				local row_lbl = `row_lbl' + 3
			}
			else {
				local row_lbl = `row_lbl' + 2
			}
		}
		
		* --- Formatting: Fonts, headers and panels ---
		
		* Font sizes
		putexcel B2:N35, font("Times New Roman", 12)
		putexcel B36:N36, font("Times New Roman", 10)
		
		* Alignment
		putexcel C3:N35, hcenter vcenter
		putexcel B4:B36, vcenter
		
		* --- Headers ---
		putexcel B2:L2 = "Table 3. Analysis of scape out of poverty between 1998  - 2007 (OLS), household-level information", merge hcenter border(bottom)
		putexcel B3 = "Dependent Variable: Scape out of poverty (poor in 1998 and non-poor 2007=1)", txtwrap hcenter vcenter
		putexcel B3:L3, border(bottom, double)

		* --- Regression headers ---
		forvalues i = 1/12 {
			putexcel `=char(`i'+66)'3 = "(`i')",
		}
		
		* Column subtitles
		putexcel B4 = "Conflict exposure, Village level", italic underline
		putexcel B11 = "Conflict exposure, Household level", italic underline
		
		* --- Summary stats labels ---
		putexcel B30:N30, border(top)
		putexcel B30 = "Observations", italic
		putexcel B31 = "Mean Dependent Variable", italic
		putexcel B32 = "Household Head Controls 1998", italic
		putexcel B33 = "Household Controls 1998", italic
		putexcel B34 = "Village Controls", italic
		putexcel B35 = "Province time-trend", italic
		
		forvalues i = 3/14 {
			putexcel `=char(`i'+64)'32 = "Yes", italic
			putexcel `=char(`i'+64)'33 = "Yes", italic
			putexcel `=char(`i'+64)'34 = "Yes", italic
			putexcel `=char(`i'+64)'35 = "Yes", italic

		}

		* --- Footnote ---
		putexcel B36:N36 = ///
		"Notes - This table presents the probit analysis of scape out of poverty between 1998 and 2007. Marginal effects reported. Robust standard error, clustered at Village level. * p<0.10  ** p<0.05 *** p<0.01. The dependent variable, Scape out of poverty (poor in 1998 and non-poor 2007=1), takes 1 when a poor household in 1998 became non-poor in 2007 (i.e. scape out of poverty). Household and household Head Controls 1998 includes: Household head sex (1998) (female=1), Household head age (1998), Household head knows how to read and write (1998), Tropical Livestock Units. Village Controls:Altitude (mts over sea level), Average Rainfall 1998-2007 and Average Temperature 1998-2007. Indexes  of Asset Related Losses refers - PCA -  refers to the first component from a Principal Component Analysis for Theft of money (yes=1), Theft or destruction of goods (yes=1), and Destruction of house (yes=1)  for a household in a given year. Data Source: 2007 Burundi Priority Panel Survey", ///
		merge txtwrap border(top)

		* --- Format with xl() ---
		mata
			b = xl()
			b.load_book("$results")
			b.set_sheet("Table 3")
			// Remove gridlines and set background white
			b.set_sheet_gridlines("Table 3", "off")
			// Column widths
			b.set_column_width(2,2,60)
			b.set_column_width(3,14,14)
			// Row heights
			b.set_row_height(3, 3, 50)
			b.set_row_height(4, 4, 25)
			b.set_row_height(11, 11, 25)
			b.set_row_height(36, 36, 50)
			b.close_book()
		end