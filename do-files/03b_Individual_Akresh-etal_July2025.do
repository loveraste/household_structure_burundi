*--------------------------------------------*
*---- Civil War and Household Composition ---*
*------ Akresh, Muñoz and Verwimp (2025) ----*
*------ 	 TABLES INDIVIDUAL  		 ----*
*------ 	  July 1, 2025  		     ----*
*--------------------------------------------*
*--------------------------------------------*
 
* --- --- --- --- --- --- --- --- --- 
* We include the data preliminaries 
* --- --- --- --- --- --- --- --- --- 
  
	run "$path_work/do-files/00_DataPreliminaries_Akresh-etal_2025.do"
	global results "out/Akresh_etal_20250708_individual.xlsx" 
  
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
		global tables_ind d_violence deathwounded_100 sk_vl_rob_land sk_vl_rob_product sk_vl_rob_money sk_vl_rob_goods sk_vl_rob_destruction pca_agri pca_asset pca_all
		
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
		merge m:1 id_hh year using "$path_work/data/job/pca.dta", nogen keep(1 3)

* --- --- --- --- --- --- --- --- --- 
* TABLE I
* Summary Statistics 1997-2008
* --- --- --- --- --- --- --- --- --- 
		
		putexcel set "${results}", modify sheet("Table 1") 
		
		* --- Formatting: Fonts and headers ---
		putexcel B1:E1 = "Table 1: Summary statistics", merge hcenter border(bottom)
		putexcel C2:E2 = "Without marital migration", merge hcenter vcenter bold

		* Header labels
		putexcel B3 = "Variable", hcenter
		putexcel C3 = "Obs", hcenter
		putexcel D3 = "Mean", hcenter
		putexcel E3 = "Std. Dev.", hcenter
		putexcel B3:E3, border(bottom, double)

		* Alignment
		putexcel C4:E40, hcenter vcenter
		putexcel B1:B41, vcenter

		* Font sizes
		putexcel B1:E3, font("Times New Roman", 12)
		putexcel B4:E40, font("Times New Roman", 11)
		putexcel B41:E41, font("Times New Roman", 10)
		
		* --- Program to export results ---
		cap program drop export_table1
		program define export_table1
			// Define named options for clarity and flexibility
			syntax varlist , Section(string) Startrow(integer) [If(string)]

			* Write section title
			putexcel B`startrow' = "`section'", italic underline

			* Get summary statistics
			if "`if'" != "" {
				qui estpost tabstat `varlist' if `if', stats(n mean sd) columns(statistics)
			}
			else {
				qui estpost tabstat `varlist', stats(n mean sd) columns(statistics)
			}

			* Export statistics to Excel
			local stat_row = `startrow' + 1
			putexcel C`stat_row' = matrix(e(count)') ///
					 D`stat_row' = matrix(e(mean)') ///
					 E`stat_row' = matrix(e(sd)')
					 
			* Write variable labels
			local row = `stat_row'
			foreach v of varlist `varlist' {
				putexcel B`row' = "`: variable label `v''"
				local ++row
			}

			* Add dotted border after last row
			local last_row = `row' - 1
			putexcel B`last_row':E`last_row', border(bottom, dotted)
		end
		
		* --- Export each observation level ---
		* Individual-year level 
		export_table1 d_violence deathwounded_100 leave , section("Individual-year level") startrow(4)
		* Individual level 
		export_table1 d_leave_ind , section("Individual level") startrow(8) if(n_ind == 1)
		* Household-year level
		export_table1 ///
			d_violence deathwounded_100 d_leave_hh leave_hh ///
			sk_vl_rob_money sk_vl_rob_product sk_vl_rob_goods sk_vl_rob_destruction sk_vl_rob_land ///
			pca_agri pca_asset pca_all , ///
			section("Household-year level") startrow(10) if(hh == 1)
		* Household level	
		export_table1 ///
			hh_d_violence hh_deathwounded d_leave_hh_t leave_hh_t ///
			hh_sk_vl_rob_money hh_sk_vl_rob_product hh_sk_vl_rob_goods hh_sk_vl_rob_destruction hh_sk_vl_rob_land ///
			pca_agri_hh pca_asset_hh pca_all_hh , ///
			section("Household level") startrow(23) if(n_hh == 1)
		* Village-year level
		export_table1 v_deathwounded v_d_violence , section("Village-year level") startrow(36) if(n_vill_y == 1)
		* Village level			
		export_table1 v1_d_violence , section("Village level") startrow(39) if(n_vill == 1)
		putexcel B40 = "Fraction of villages that ever experienced violence at least one year during 1998-2007", txtwrap
		
		* -- Footnote ---
		putexcel B41:E41 = "Notes - This table presents the main descriptive statistics at different observation levels. Violence in a given year (yes=1)  takes the value one if the number of casualties in a given year is positive, 0 otherwise. Number of causalties in a given year measures the number of individuals killed or wounded in a given year (divided by 100).  Index of household Losses (all) - PCA -  referes to the first component from a Principal Component Analysis for the five different type of losses at household level (i.e. money, crops, destruction of goods, destrution of house and loss of land). Index of Agricultural Related Losses - PCA -  refers to the first component from a Principal Component Analysis for the Loss of land (yes=1) and Theft of crops (yes=1) for a household in a given year. Index of Asset Related Losses refers - PCA -  refers to the first component from a Principal Component Analysis for Theft of money (yes=1), Theft or destruction of goods (yes=1), and Destruction of house (yes=1)  for a household in a given year. Data Source: 2007 Burundi Priority Panel Survey.", ///
		merge txtwrap border(top, medium)
		
		* --- Excel post-formatting using xl() ---
		mata
			b = xl()
			b.load_book("${results}")
			b.set_sheet("Table 1")
			// Remove gridlines
			b.set_sheet_gridlines("Table 1", "off")
			//  Column widths
			b.set_column_width(2, 2, 70) 
			b.set_column_width(3, 5, 14.5)
			// Row heights
			b.set_row_height(2, 2, 41) 
			b.set_row_height(2, 2, 41)
			b.set_row_height(4, 4, 20)
			b.set_row_height(8, 8, 20)
			b.set_row_height(10,10,20)
			b.set_row_height(23,23,20)
			b.set_row_height(36,36,20)
			b.set_row_height(39,39,20)
			b.set_row_height(40,40,30)
			b.set_row_height(41,41,128.25)
			// Numeric format (3 decimals) 
			b.set_number_format((5, 40), (4, 5), "0.000") 
			b.close_book()
		end
			
			
* --- --- --- --- --- --- --- --- --- 
* TABLE II
* Cross tabulation
* --- --- --- --- --- --- --- --- ---
		preserve
		keep if n_ind == 1 & !missing(d_leave_ind) & !missing(pca_all)
		* Generate individual-level variables
		egen pca_mean=mean(pca_all)
		egen deathwounded_mean=mean(deathwounded_100)
		
		gen pca_above = (pca_all > pca_mean) 
		gen d_deathwounded = (deathwounded_100 >= deathwounded_mean) 

		* Generate household-level violence variables
		putexcel set "${results}", modify sheet("Table 2") 

		*** Violence 
		estpost tabstat  d_violence if pca_above==0, by(d_violence) stats(n)  columns(statistics)
		putexcel C6=matrix(e(count)')

		estpost tabstat  d_leave_ind if pca_above==0, by(d_violence) stats(mean)  columns(statistics)
		putexcel D6=matrix(e(mean)')
		
		estpost tabstat  d_violence if pca_above==1, by(d_violence) stats(n)  columns(statistics)
		putexcel E6=matrix(e(count)')

		estpost tabstat  d_leave_ind if pca_above==1, by(d_violence) stats(mean)  columns(statistics)
		putexcel F6=matrix(e(mean)')

		*** d_hh_deathwounded
		estpost tabstat  d_deathwounded if pca_above==0, by(d_deathwounded) stats(n)  columns(statistics)
		putexcel C10=matrix(e(count)')

		estpost tabstat  d_leave_ind if pca_above==0, by(d_deathwounded) stats(mean)  columns(statistics)
		putexcel D10=matrix(e(mean)')
		
		estpost tabstat  d_deathwounded if pca_above==1, by(d_deathwounded) stats(n)  columns(statistics)
		putexcel E10=matrix(e(count)')

		estpost tabstat  d_leave_ind if pca_above==1, by(d_deathwounded) stats(mean)  columns(statistics)
		putexcel F10=matrix(e(mean)')

		* --- Formatting: Fonts, headers and panels ---
		putexcel B2:F2 = "Table 2: Cross-tabulation of household migration over different violence exposure", merge hcenter border(bottom)
		
		* Font sizes
		putexcel B2:F12, font("Times New Roman", 12)
		putexcel B13:F13, font("Times New Roman", 10)
		
		* Alignment
		putexcel C3:F12, hcenter vcenter
		putexcel B5:B13, vcenter
		
		* Column subtitles
		putexcel C3:D3 = "Index of household Losses (all) - PCA below mean", merge txtwrap
		putexcel E3:F3 = "Index of household Losses (all) - PCA above mean", merge txtwrap
		putexcel C4 = "Observations", 
		putexcel D4 = "Share of migration", 
		putexcel E4 = "Observations", 
		putexcel F4 = "Share of migration", 
		putexcel B4:F4, border(bottom, double)

		* Panel A
		putexcel B5 = "Panel A", bold underline
		putexcel B6 = "Villages that never experienced violence during 1998–2007", txtwrap 
		putexcel B7 = "Villages that experienced violence in at least 1 year during 1998–2007", txtwrap 
		putexcel B8 = "Total Observations", italic 
		putexcel B8:F8, border(bottom, dotted)

		* Panel B
		putexcel B9 = "Panel B", bold underline
		putexcel B10 = "Number of casualties during 1998–2007 below the mean", txtwrap
		putexcel B11 = "Number of casualties during 1998–2007 above the mean", txtwrap
		putexcel B12 = "Total Observations", italic 
		
		* Delete unnecessary values
		putexcel D8 = "" 
		putexcel F8 = ""
		putexcel D12 = ""
		putexcel F12 = ""
		
		* Notas
		putexcel B13:F13 = ///
		"Notes - * p<0.10  ** p<0.05  *** p<0.01. Standard deviation in brackets, Standard errors in parenthesis. Two-sided mean test reported. We only consider non-marital migration sample. Data Source: 2007 Burundi Priority Panel Survey.", ///
		merge txtwrap border(top)

		* --- Excel post-formatting using xl() ---
		mata
			b = xl()
			b.load_book("${results}")
			b.set_sheet("Table 2")
			// Gridlines off
			b.set_sheet_gridlines("Table 2", "off")
			// Column widths
			b.set_column_width(2,2,45)     
			b.set_column_width(3,6,15) 
			// Row heights
			b.set_row_height(3, 3, 38)
			b.set_row_height(5, 12, 30)
			b.set_row_height(13, 13, 28)
			// Numeric format
			b.set_number_format((6,12), 4, "0.000") 
			b.set_number_format((6,12), 6, "0.000") 
			b.close_book()
		end

		restore

* --- --- --- --- --- --- --- --- --- 
* TABLE III
* --- --- --- --- --- --- --- --- ---
		
		* --- Regressions
		eststo clear
		foreach j in $tables_ind {
			quietly xtreg leave `j' i.year province_trend, fe cluster(reczd)
			quietly summarize leave if e(sample)
			qui estadd scalar depmean = r(mean)  
			eststo `j' 
		}
		
		* Set excel sheet
		putexcel set "$results", sheet("Table 3") modify  
		
		local col = 3
		local row = 5
		local row_s = 26    
		
		foreach j of global tables_ind {

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
			if "`j'" == "deathwounded_100" {
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
		foreach v of varlist $tables_ind {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"

			if "`v'" == "deathwounded_100" {
				local row_lbl = `row_lbl' + 3
			}
			else {
				local row_lbl = `row_lbl' + 2
			}
		}
		
		* --- Formatting: Fonts, headers and panels ---
		
		* Font sizes
		putexcel B2:L30, font("Times New Roman", 12)
		putexcel B31:L31, font("Times New Roman", 10)
		
		* Alignment
		putexcel C3:L30, hcenter vcenter
		putexcel B4:B31, vcenter
		
		* --- Headers ---
		putexcel B2:L2 = "Table 3. Baseline results. Armed Conflict and Non-Marital Migration, Individual-level Analysis", merge hcenter border(bottom)
		putexcel B3 = "Dependent Variable: Migration outside household in a given year (yes=1)", txtwrap hcenter vcenter
		putexcel B3:L3, border(bottom, double)

		* --- Regression headers ---
		forvalues i = 1/10 {
			putexcel `=char(`i'+66)'3 = "(`i')",
		}
		
		* Column subtitles
		putexcel B4 = "Conflict exposure, Village level", italic underline
		putexcel B9 = "Conflict exposure, Household level", italic underline
		
		* --- Summary stats labels ---
		putexcel B26:L26, border(top)
		putexcel B26 = "Observations", italic
		putexcel B27 = "Mean Dependent Variable", italic
		putexcel B28 = "Household Fixed Effect", italic
		putexcel B29 = "Year Fixed Effect", italic
		putexcel B30 = "Province time-trend", italic
		
		forvalues i = 3/12 {
			putexcel `=char(`i'+64)'28 = "Yes", italic
			putexcel `=char(`i'+64)'29 = "Yes", italic
			putexcel `=char(`i'+64)'30 = "Yes", italic
		}

		* --- Footnote ---
		putexcel B31:L31 = ///
		"Notes - This table presents our baseline regression for non-marital migration at individual level. Robust standard errors, clustered at VIllage level. * p<0.10  ** p<0.05 *** p<0.01. The dependent variable, Migration outside of the household in a given year (yes=1) takes value one when a person migrates due to non-marital reasons in a given year. Sample includes all household members that either never migrate or migrate for non-marital reasons during 1998-2007. Violence in a given year (presence=1)   takes value one when the number of casualties in a given year is positive, 0 otherwise. Number of casualties in a given year includes the number of individuals killed or wounded in a given year, divided by 100 people. Index of Asset Related Losses refers - PCA -  refers to the first component from a Principal Component Analysis for Theft of money (yes=1), Theft or destruction of goods (yes=1), and Destruction of house (yes=1)  for a household in a given year.  Data Source: 2007 Burundi Priority Panel Survey. Data Source: 2007 Burundi Priority Panel Survey.", ///
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
			b.set_column_width(3,12,14)
			// Row heights
			b.set_row_height(3, 3, 50)
			b.set_row_height(4, 4, 25)
			b.set_row_height(9, 9, 25)
			b.set_row_height(31, 31, 55)
			b.close_book()
		end
		
* --- --- --- --- --- --- --- --- --- --- ---
* TABLE IV 
* --- --- --- --- --- --- --- --- --- --- ---
	    
		* --- Variables	
		global base_vars4 "d_violence deathwounded_100 pca_asset pca_all"
		
		* Run regressions and store
		eststo clear
		local count = 1
		foreach sample in "if sex==1" "if sex==0" "if adult_18==1" "if adult_18==0" "if pov_stat98==1" "if pov_stat98==0" {
			foreach j of global base_vars4 {
				qui xtreg leave `j' i.year province_trend `sample' , cluster(reczd) fe 
				eststo model_`count'
				qui summarize leave if e(sample)
				qui estadd scalar depmean = r(mean)
				local ++count
			}	
		}
		
		* Set sheet
		putexcel set "$results", sheet("Table 4") modify
		
		local col = 3   
		local row = 7  
		local row_s = 19
		
		forvalues i = 1/24 {
			
			* --- Restore current model ---
			est restore model_`i'
			
			* Identify variables
			local x = e(cmdline)
			foreach v in $base_vars4 {
				if strpos("`x'", "`v'") local vvar = "`v'"
			}

			* --- Extract estimates ---
			scalar bv = _b[`vvar']
			scalar se_v = _se[`vvar']
			scalar p_v = 2*ttail(e(df_r), abs(bv/se_v))
			local sv = ""
			if p_v < .01 local sv = "***"
			else if p_v < .05 local sv = "**"
			else if p_v < .10 local sv= "*"
			
			scalar depm = e(depmean)
			scalar obs  = e(N)
			
			* --- Format values ---
			local bvfmt = string(bv, "%9.3f")
			local sevfmt = string(se_v, "%9.3f")
			local depm    = string(depm, "%9.3f")  
			local obs     = string(obs, "%9.0f")  

			* --- Export coefficient and standar error with stars ---
			putexcel `=char(`col'+64)'`row' = ("`bvfmt'`sv'")
			putexcel `=char(`col'+64)'`=`row'+1' = ("[`sevfmt']")
			putexcel `="B" + string(`row'+1) + ":H" + string(`row'+1)' , border(bottom, dotted)
			
			* --- Export regression statistics below the table ---
			putexcel `=char(`col'+64)'`row_s' = `obs', overwrite italic
			local row_s1=`row_s'+1
			putexcel `=char(`col'+64)'`row_s1' = `depm', overwrite italic
			
			* Update row and column
			
			if "`vvar'" == "deathwounded_100" {
				local row = `row' + 4
			} 
			else {
				local row = `row' + 3
			}
			
			if inlist(`i', 4, 8, 12, 16, 20) {
				local row = 7  
				local col = `col' + 1
			}
		}
		
		* Write variable labels
		local row_lbl = 7
		foreach v of varlist $base_vars4 {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
			if "`v'" == "deathwounded_100" {
				local row_lbl = `row_lbl' + 4
			}
			else {
				local row_lbl = `row_lbl' + 3
			}
		}
		
		* --- Formatting: Fonts, headers and panels ---
		
		* Font sizes
		putexcel B2:H33, font("Times New Roman", 12)
		putexcel B24:H24, font("Times New Roman", 10)
		
		* Alignment
		putexcel C3:H23, hcenter vcenter
		putexcel B4:B24, vcenter
		
		* --- Headers ---
		putexcel B2:H2 = "Table 4. Baseline results. Armed Conflict and Migration, Individual-level Analysis", merge hcenter border(bottom)
		putexcel B3:B4 = "Dependent Variable: Migration outside household in a given year (yes=1)", txtwrap hcenter vcenter merge
		putexcel C3 = "Only women", txtwrap
		putexcel D3 = "Only men", txtwrap
		putexcel E3 = "Adults (older than 18 years old)", txtwrap
		putexcel F3 = "Children (younger than 18 years old)", txtwrap
		putexcel G3 = "Poor Households (1998)", txtwrap
		putexcel H3 = "Non-Poor Households (1998)", txtwrap
		putexcel B4:H4, border(bottom, double)

		* --- Regression headers ---
		forvalues i = 1/6 {
			putexcel `=char(`i'+66)'4 = "(`i')",
		}
		
		* Column subtitles
		putexcel B5 = "Conflict exposure, Village level", italic underline bold
		putexcel B6 = "Panel A", italic underline
		putexcel B9 = "Panel B", italic underline
		putexcel B12 = "Conflict exposure, Household level", italic underline bold
		putexcel B13 = "Panel C", italic underline
		putexcel B16 = "Panel D", italic underline
		
		* --- Summary stats labels ---
		putexcel B19:H19, border(top)
		putexcel B19 = "Observations", italic
		putexcel B20 = "Mean Dependent Variable", italic
		putexcel B21 = "Individual Fixed Effect", italic
		putexcel B22 = "Year Fixed Effect", italic
		putexcel B23 = "Province time-trend", italic
		
		forvalues i = 3/8 {
			putexcel `=char(`i'+64)'21 = "Yes", italic
			putexcel `=char(`i'+64)'22 = "Yes", italic
			putexcel `=char(`i'+64)'23 = "Yes", italic
		}
		
		* --- Footnote ---
		putexcel B24:H24= ///
		"Notes - This table presents our heterogeneity analysis for non-marital migration at individual level. Robust standard errors, clustered at VIllage level. * p<0.10  ** p<0.05 *** p<0.01. The dependent variable, Migration outside of the household in a given year (yes=1) takes value one when a person migrates in a given year. Columns (1) to (4) restricts the baseline sample to only women, only men, only adults (older than 18 years old) or only young (younger than 18 years old), respectively. Columns (5) and (6) split the baseline sample defining poverty based on the 1997 national Burundi poverty line. Violence in a given year (presence=1)   takes value one when the number of casualties in a given year is positive, 0 otherwise. Number of casualties in a given year includes the number of individuals killed or wounded in a given year, divided by 100 people.Index of Asset Related Losses refers - PCA -  refers to the first component from a Principal Component Analysis for Theft of money (yes=1), Theft or destruction of goods (yes=1), and Destruction of house (yes=1)  for a household in a given year.  Data Source: 2007 Burundi Priority Panel Survey.", ///
		merge txtwrap border(top)

		* --- Format with xl() ---
		mata
			b = xl()
			b.load_book("$results")
			b.set_sheet("Table 4")
			// Remove gridlines and set background white
			b.set_sheet_gridlines("Table 4", "off")
			// Column widths
			b.set_column_width(2,2,60)
			b.set_column_width(3,12,15)
			// Row heights
			b.set_row_height(3, 3, 50)
			b.set_row_height(5, 6, 25)
			b.set_row_height(9, 9, 25)
			b.set_row_height(12, 13, 25)
			b.set_row_height(16, 16, 25)
			b.set_row_height(24, 24, 90)
			b.close_book()
		end
		
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
		foreach j of global tables_ind {
			quietly xtreg leave `j' lag_`j' i.year province_trend, fe cluster(reczd)
			*store the mean
			quietly summarize leave if e(sample)
			qui estadd scalar depmean = r(mean)  
			eststo `j'                            
		}

		*** Export results to Excel
		putexcel set "$results", sheet("Table 5") modify  

		local col = 3
		local row = 5
		local row_s = 46      

		foreach j of global tables_hh {

			* --- Restore current model ---
			est restore `j'

			* --- Extract estimates ---
			scalar b  = _b[`j']
			scalar bL  = _b[lag_`j']
			scalar se = _se[`j']
			scalar seL = _se[lag_`j']
			scalar p  = 2*ttail(e(df_r), abs(b/se))
			scalar pL  = 2*ttail(e(df_r), abs(bL/seL))
			scalar depm = e(depmean)
			scalar obs  = e(N)

			* --- Build stars for significance ---
			local stars ""
			if      (p < .01) local stars "***"
			else if (p < .05) local stars "**"
			else if (p < .10) local stars "*"
			local starsL ""
			if (pL<.01)      local starsL "***"
			else if (pL<.05) local starsL "**"
			else if (pL<.10) local starsL "*"
			* --- Format values ---
			local bL_fmt  = string(bL, "%9.3f")	   // Coefficient Lag
			local seL_fmt = string(seL, "%9.3f")   // Standard error Lag
			local b_fmt   = string(b, "%9.3f")     // Coefficient
			local se_fmt  = string(se, "%9.3f")    // Standard error
			local depm    = string(depm, "%9.3f")  // Mean of dependent variable
			local obs     = string(obs, "%9.0f")   // Number of observations
			
			* --- Export coefficient and standar error with stars ---
			putexcel `=char(`col'+64)'`row' = ("`b_fmt'`stars'"), overwrite
			local r1=`row'+1
			putexcel `=char(`col'+64)'`r1' = ("[`se_fmt']"), overwrite
			local r2=`row'+2
			putexcel `=char(`col'+64)'`r2' = ("`bL_fmt'`starsL'"), overwrite
			local r3=`row'+3
			putexcel `=char(`col'+64)'`r3' = ("[`seL_fmt']"), overwrite

			* --- Export regression statistics below the table ---
			putexcel `=char(`col'+64)'`row_s' = `obs', overwrite italic
			local row_s1=`row_s'+1
			putexcel `=char(`col'+64)'`row_s1' = `depm', overwrite italic

			* --- Leave extra space after deathwounded_100 ----
			if "`j'" == "deathwounded_100" {
				local row = `row' + 3
				putexcel B`row':L`row', border(bottom)
				local row = `row' + 2 
			} 
			else {
				local row = `row' + 4
			}		
			local col = `col' + 1
		}

		
		* Write variable labels
		local row_lbl = 5
		foreach v of varlist $tables_ind {
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
		
		* --- Formatting: Fonts, headers and panels ---
		
		* Font sizes
		putexcel B2:L50, font("Times New Roman", 12)
		putexcel B51:L51, font("Times New Roman", 10)
		
		* Alignment
		putexcel C3:L50, hcenter vcenter
		putexcel B4:B51, vcenter
		
		* --- Headers ---
		putexcel B2:L2 = "Table 5. Armed Conflict and Non-Marital Migration using lags, Individual-level Analysis", merge hcenter border(bottom)
		putexcel B3 = "Dependent Variable:  Migration outside household in a given year (yes=1)", txtwrap hcenter vcenter
		putexcel B3:L3, border(bottom, double)

		* --- Regression headers ---
		forvalues i = 1/10 {
			putexcel `=char(`i'+66)'3 = "(`i')",
		}
		
		* Column subtitles
		putexcel B4 = "Conflict exposure, Village level", italic underline
		putexcel B13 = "Conflict exposure, Household level", italic underline
		
		* --- Summary stats labels ---
		putexcel B46:L46, border(top)
		putexcel B46 = "Observations", italic
		putexcel B47 = "Mean Dependent Variable", italic
		putexcel B48 = "Individual Fixed Effect", italic
		putexcel B49 = "Year Fixed Effect", italic
		putexcel B50 = "Province time-trend", italic
		
		forvalues i = 3/12 {
			putexcel `=char(`i'+64)'48 = "Yes", italic
			putexcel `=char(`i'+64)'49 = "Yes", italic
			putexcel `=char(`i'+64)'50 = "Yes", italic
		}

		* --- Footnote ---
		putexcel B51:L51 = ///
		"Notes - This table presents our baseline regression for non-marital migration at individual level. Robust standard errors, clustered at Village level. * p<0.10  ** p<0.05 *** p<0.01. The dependent variable, Migration outside of the household in a given year (yes=1) takes value one when a person migrates due to non-marital reasons in a given year. Sample includes all household members that either never migrate or migrate for non-marital reasons during 1998-2007. Violence in a given year (presence=1)   takes value one when the number of casualties in a given year is positive, 0 otherwise. Number of casualties in a given year includes the number of individuals killed or wounded in a given year, divided by 100 people. Index of Asset Related Losses refers - PCA -  refers to the first component from a Principal Component Analysis for Theft of money (yes=1), Theft or destruction of goods (yes=1), and Destruction of house (yes=1)  for a household in a given year.  Data Source: 2007 Burundi Priority Panel Survey. Data Source: 2007 Burundi Priority Panel Survey.", ///
		merge txtwrap border(top)

		* --- Format with xl() ---
		mata
			b = xl()
			b.load_book("$results")
			b.set_sheet("Table 5")
			// Remove gridlines and set background white
			b.set_sheet_gridlines("Table 5", "off")
			// Column widths
			b.set_column_width(2,2,65)
			b.set_column_width(3,12,14)
			// Row heights
			b.set_row_height(3, 3, 50)
			b.set_row_height(4, 4, 25)
			b.set_row_height(13, 13, 25)
			b.set_row_height(51, 51, 60)
			b.close_book()
		end
		
* --- --- --- --- --- --- --- --- --- --- ---
* TABLE VI
* --- --- --- --- --- --- --- --- --- --- ---
	
		* --- Variables	
		global base_vars6 "d_violence deathwounded_100 pca_agri pca_asset pca_all"
		
		* * Estimate subgroup regression and store
		eststo clear
		local count = 1
		foreach sample in "if sex==1" "if sex==0" "if adult_18==1" "if adult_18==0" "if pov_stat98==1" "if pov_stat98==0" {
			foreach j of global base_vars6 {
				qui xtreg leave `j'  lag_`j' i.year province_trend `sample' , cluster(reczd) fe 
				eststo model_`count'
				qui summarize leave if e(sample)
				qui estadd scalar depmean = r(mean)
				local ++count
			}	
		}
		
		* Set sheet
		putexcel set "$results", sheet("Table 6") modify
		
		local col = 3   
		local row = 7  
		local row_s = 32
		
		forvalues i = 1/30 {
			
			* --- Restore current model ---
			est restore model_`i'
			
			* Identify variables
			local x = e(cmdline)
			foreach v in $base_vars6 {
				if strpos("`x'", "`v'") local vvar = "`v'"
			}
			
			local lag_vvar = "lag_`vvar'"

			* --- Extract estimates ---
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
			
			scalar depm = e(depmean)
			scalar obs  = e(N)
			
			* --- Format values ---
			local bvfmt = string(bv, "%9.3f")
			local sevfmt = string(se_v, "%9.3f")
			local blagvfmt = string(blagv, "%9.3f")
			local selagvfmt = string(se_lagv, "%9.3f")
			local depm    = string(depm, "%9.3f")  
			local obs     = string(obs, "%9.0f")  

			* --- Export coefficient and standar error with stars ---
			putexcel `=char(`col'+64)'`row' = ("`bvfmt'`sv'")
			putexcel `=char(`col'+64)'`=`row'+1' = ("[`sevfmt']")
			putexcel `=char(`col'+64)'`=`row'+2' = ("`blagvfmt'`slagv'")
			putexcel `=char(`col'+64)'`=`row'+3' = ("[`selagvfmt']")
			putexcel `="B" + string(`row'+3) + ":H" + string(`row'+3)' , border(bottom, dotted)
			
			* --- Export regression statistics below the table ---
			putexcel `=char(`col'+64)'`row_s' = `obs', overwrite italic
			local row_s1=`row_s'+1
			putexcel `=char(`col'+64)'`row_s1' = `depm', overwrite italic
			
			* Update row and column	
			if "`vvar'" == "deathwounded_100" {
				local row = `row' + 6
			} 
			else {
				local row = `row' + 5
			}
			
			if inlist(`i', 5, 10, 15, 20, 25) {
				local row = 7  
				local col = `col' + 1
			}
		}
		
		* Write variable labels
		local row_lbl = 7
		foreach v of varlist $base_vars6 {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
			local row_lbl = `row_lbl' + 2
			putexcel B`row_lbl' = "Lag `lbl'"
			local row_lbl = `row_lbl' + 3
			if "`v'" == "deathwounded_100" {
				local row_lbl = `row_lbl' + 1
			}
		}
		
		* --- Formatting: Fonts, headers and panels ---
		
		* Font sizes
		putexcel B2:H36, font("Times New Roman", 12)
		putexcel B37:H37, font("Times New Roman", 10)
		
		* Alignment
		putexcel C3:H36, hcenter vcenter
		putexcel B4:B37, vcenter
		
		* --- Headers ---
		putexcel B2:H2 = "Table 6. Armed Conflict and Non-Marital Migration using lags, Individual-level Analysis", merge hcenter border(bottom)
		putexcel B3:B4 = "Dependent Variable: Migration outside household in a given year (yes=1)", txtwrap hcenter vcenter merge
		putexcel C3 = "Only women", txtwrap
		putexcel D3 = "Only men", txtwrap
		putexcel E3 = "Adults (older than 18 years old)", txtwrap
		putexcel F3 = "Children (younger than 18 years old)", txtwrap
		putexcel G3 = "Poor Households (1998)", txtwrap
		putexcel H3 = "Non-Poor Households (1998)", txtwrap
		putexcel B4:H4, border(bottom, double)

		* --- Regression headers ---
		forvalues i = 1/6 {
			putexcel `=char(`i'+66)'4 = "(`i')",
		}
		
		* Column subtitles
		putexcel B5 = "Conflict exposure, Village level", italic underline bold
		putexcel B6 = "Panel A", italic underline
		putexcel B11 = "Panel B", italic underline
		putexcel B16 = "Conflict exposure, Household level", italic underline bold
		putexcel B17 = "Panel C", italic underline
		putexcel B22 = "Panel D", italic underline
		putexcel B27 = "Panel E", italic underline
		
		* --- Summary stats labels ---
		putexcel B32:H32, border(top)
		putexcel B32 = "Observations", italic
		putexcel B33 = "Mean Dependent Variable", italic
		putexcel B34 = "Individual Fixed Effect", italic
		putexcel B35 = "Year Fixed Effect", italic
		putexcel B36 = "Province time-trend", italic
		
		forvalues i = 3/8 {
			putexcel `=char(`i'+64)'34 = "Yes", italic
			putexcel `=char(`i'+64)'35 = "Yes", italic
			putexcel `=char(`i'+64)'36 = "Yes", italic
		}
		
		* --- Footnote ---
		putexcel B37:H37= ///
		"Notes - This table presents our heterogeneity analysis for non-marital migration at individual level. Robust standard errors, clustered at Village level. * p<0.10  ** p<0.05 *** p<0.01. The dependent variable, Migration outside of the household in a given year (yes=1) takes value one when a person migrates in a given year. Columns (1) to (4) restricts the baseline sample to only women, only men, only adults (older than 18 years old) or only young (younger than 18 years old), respectively. Columns (5) and (6) split the baseline sample defining poverty based on the 1997 national Burundi poverty line. Violence in a given year (presence=1)   takes value one when the number of casualties in a given year is positive, 0 otherwise. Number of casualties in a given year includes the number of individuals killed or wounded in a given year, divided by 100 people.Index of Asset Related Losses refers - PCA -  refers to the first component from a Principal Component Analysis for Theft of money (yes=1), Theft or destruction of goods (yes=1), and Destruction of house (yes=1)  for a household in a given year.  Data Source: 2007 Burundi Priority Panel Survey.", ///
		merge txtwrap border(top)

		* --- Format with xl() ---
		mata
			b = xl()
			b.load_book("$results")
			b.set_sheet("Table 6")
			// Remove gridlines and set background white
			b.set_sheet_gridlines("Table 6", "off")
			// Column widths
			b.set_column_width(2,2,70)
			b.set_column_width(3,12,15)
			// Row heights
			b.set_row_height(3, 3, 50)
			b.set_row_height(5, 6, 25)
			b.set_row_height(11, 11, 25)
			b.set_row_height(16, 17, 25)
			b.set_row_height(22, 22, 25)
			b.set_row_height(27, 27, 25)
			b.set_row_height(37, 37, 90)
			b.close_book()
		end
		
		
* --- --- --- --- --- --- --- --- --- --- --- --- ---
* TABLE VII
* --- --- --- --- --- --- --- --- --- --- --- --- ---
		
		*  Variables to interact
		global base_vars7 "d_violence deathwounded_100"
		global pca_vars7 "pca_asset pca_all"

		** Run regressions and store
		eststo clear
		local count = 1
		foreach x in $base_vars7 {
			foreach z in $pca_vars7 {
				qui xtreg leave `x' `z' i.year province_trend, fe cluster(reczd)
				eststo model_`count'
				qui summarize leave if e(sample)
				qui estadd scalar depmean = r(mean)
				local ++count
			}
		}
		
		* Set sheet
		putexcel set "$results", sheet("Table 7") modify

		local col = 3   
		local row = 5   
		local row_pca_start = 10
		local row_s = 14   

		forvalues i = 1/4 {
			
			* --- Restore current model ---
			est restore model_`i'
			
			* Identify variables
			local x = e(cmdline)
			foreach v in $base_vars7 {
				if strpos("`x'", "`v'") local vvar = "`v'"
			}
			foreach z in $pca_vars7 {
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
		
			* --- Export coefficient and standar error with stars ---
			putexcel `=char(`col'+64)'`row' = ("`bvfmt'`sv'")
			putexcel `=char(`col'+64)'`=`row'+1' = ("[`sevfmt']")

			if `i' == 2 | `i' == 4 {
				local row_pca_start = `row_pca_start' + 2
			}
			else if `i' == 3 {
				local row_pca_start = `row_pca_start' - 2
			}

			local row_z = `row_pca_start'
			putexcel `=char(`col'+64)'`row_z' = ("`bzfmt'`sz'")
			putexcel `=char(`col'+64)'`=`row_z'+1' = ("[`sezfmt']")

			* --- Export regression statistics below the table ---
			putexcel `=char(`col'+64)'`row_s' = `obs', overwrite italic
			local row_s1=`row_s'+1
			putexcel `=char(`col'+64)'`row_s1' = `depm', overwrite italic
			
			* Update row and column
			if `i' == 2 {
				local row = `row' + 2
			}
				
			local col = `col' + 1
		}
		
		* Write variable labels
		local row_lbl = 5
		foreach v of varlist $base_vars7 {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
			local row_lbl = `row_lbl' + 2
		}
		local row_lbl = 10
		foreach v of varlist $pca_vars7 {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
			local row_lbl = `row_lbl' + 2
		}
		
		* --- Formatting: Fonts, headers and panels ---
		
		* Font sizes
		putexcel B2:F18, font("Times New Roman", 12)
		putexcel B19:L19, font("Times New Roman", 10)
		
		* Alignment
		putexcel C3:F18, hcenter vcenter
		putexcel B4:B19, vcenter
		
		* --- Headers ---
		putexcel B2:F2 = "Table 7. Baseline results. Armed Conflict and Non-Marital Migration, Individual-level Analysis", merge hcenter border(bottom)
		putexcel B3 = "Dependent Variable:  Migration outside household in a given year (yes=1)", txtwrap hcenter vcenter
		putexcel B3:F3, border(bottom, double)

		* --- Regression headers ---
		forvalues i = 1/4 {
			putexcel `=char(`i'+66)'3 = "(`i')",
		}
		
		* Column subtitles
		putexcel B4 = "Conflict exposure, Village level", italic underline
		putexcel B9 = "Conflict exposure, Household level", italic underline
		
		* --- Summary stats labels ---
		putexcel B9:F9, border(top)
		putexcel B14:F14, border(top)
		putexcel B14 = "Observations", italic
		putexcel B15 = "Mean Dependent Variable", italic
		putexcel B16 = "Individual Fixed Effect", italic
		putexcel B17 = "Year Fixed Effect", italic
		putexcel B18 = "Province time-trend", italic
		
		forvalues i = 3/6 {
			putexcel `=char(`i'+64)'16 = "Yes", italic
			putexcel `=char(`i'+64)'17 = "Yes", italic
			putexcel `=char(`i'+64)'18 = "Yes", italic
		}

		* --- Footnote ---
		putexcel B19:F19= ///
		"Notes - This table presents our baseline regression for non-marital migration at individual level. Robust standard errors, clustered at VIllage level. * p<0.10  ** p<0.05 *** p<0.01. The dependent variable, Migration outside of the household in a given year (yes=1) takes value one when a person migrates due to non-marital reasons in a given year. Sample includes all household members that either never migrate or migrate for non-marital reasons during 1998-2007. Violence in a given year (presence=1)   takes value one when the number of casualties in a given year is positive, 0 otherwise. Number of casualties in a given year includes the number of individuals killed or wounded in a given year, divided by 100 people. Index of Asset Related Losses refers - PCA -  refers to the first component from a Principal Component Analysis for Theft of money (yes=1), Theft or destruction of goods (yes=1), and Destruction of house (yes=1)  for a household in a given year.  Data Source: 2007 Burundi Priority Panel Survey. Data Source: 2007 Burundi Priority Panel Survey.", ///
		merge txtwrap border(top)

		* --- Format with xl() ---
		mata
			b = xl()
			b.load_book("$results")
			b.set_sheet("Table 7")
			// Remove gridlines and set background white
			b.set_sheet_gridlines("Table 7", "off")
			// Column widths
			b.set_column_width(2,2,65)
			b.set_column_width(3,12,14)
			// Row heights
			b.set_row_height(3, 3, 50)
			b.set_row_height(4, 4, 25)
			b.set_row_height(9, 9, 25)
			b.set_row_height(19, 19, 90)
			b.close_book()
		end
		
		
* --- --- --- --- --- --- --- --- --- --- --- --- ---
* TABLE VIII
* --- --- --- --- --- --- --- --- --- --- --- --- ---

		* Dummy: Number of casualties in a given year above mean (yes=1)
		sum deathwounded_100 if !missing(deathwounded_100)
		gen deathwounded_abovemean = (deathwounded_100 > r(mean)) if !missing(deathwounded_100)
		
		label var deathwounded_abovemean "Number of casualties in a given year above mean (yes=1)"

		* --- Variables to interact ---
		global base_vars8 "d_violence deathwounded_100 deathwounded_abovemean"
		global pca_vars8 "pca_all_abovemean pca_all"
		
		* Run regressions interacting each exposure and intensity with each PCA index
		eststo clear
		local count = 1
		foreach x in $base_vars8 {
			foreach z in $pca_vars8 {
		    qui xtreg leave c.`x'##c.`z' i.year province_trend, fe cluster(reczd)
			eststo model_`count'
			qui summarize leave if e(sample)
			qui estadd scalar depmean = r(mean)
			local ++count
			}
		}
		
		* Set sheet
		putexcel set "$results", sheet("Table 8") modify
		
		local col = 3   
		local row = 5   
		local row_pca_start = 12
		local row_int_start = 17
		local row_s = 29 
		
		forvalues i = 1/6 {
			
			* --- Restore current model ---
			est restore model_`i'
			
			* Identify variables
			local x = e(cmdline)
			foreach v in $base_vars8 {
				if strpos("`x'", "`v'") local vvar = "`v'"
			}
			foreach z in $pca_vars8 {
				if strpos("`x'", "`z'") local zvar = "`z'"
			}
			
			local interaction = "c.`vvar'#c.`zvar'"

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
			
			scalar bi = _b[`interaction']
			scalar sei = _se[`interaction']
			scalar p_i = 2*ttail(e(df_r), abs(bi/sei))
			local si = ""
			if p_i < .01 local si = "***"
			else if p_i < .05 local si = "**"
			else if p_i < .10 local si = "*"
			
			* --- Format values ---
			local bvfmt = string(bv, "%9.3f")
			local sevfmt = string(se_v, "%9.3f")
			local bzfmt = string(bz, "%9.3f")
			local sezfmt = string(sez, "%9.3f")
			local bifmt = string(bi, "%9.3f")
			local seifmt = string(sei, "%9.3f")
			local depm    = string(depm, "%9.3f")  
			local obs     = string(obs, "%9.0f")  

			* --- Export coefficient and standar error with stars ---
			putexcel `=char(`col'+64)'`row' = ("`bvfmt'`sv'")
			putexcel `=char(`col'+64)'`=`row'+1' = ("[`sevfmt']")

			if inlist(`i', 2, 4, 6) {
				local row_pca_start = `row_pca_start' + 2
			}
			else if inlist(`i', 3, 5) {
				local row_pca_start = `row_pca_start' - 2
			}

			local row_z = `row_pca_start'
			putexcel `=char(`col'+64)'`row_z' = ("`bzfmt'`sz'")
			putexcel `=char(`col'+64)'`=`row_z'+1' = ("[`sezfmt']")

			putexcel `=char(`col'+64)'`row_int_start' = ("`bifmt'`si'")
			putexcel `=char(`col'+64)'`=`row_int_start'+1' = ("[`seifmt']")
			
			local row_int_start = `row_int_start' + 2
			
			* --- Export regression statistics below the table ---
			putexcel `=char(`col'+64)'`row_s' = `obs', overwrite italic
			local row_s1=`row_s'+1
			putexcel `=char(`col'+64)'`row_s1' = `depm', overwrite italic
			
			* Update row and column
			if inlist(`i', 2, 4) {
				local row = `row' + 2
			}
				
			local col = `col' + 1
		}
		
		* Write variable labels
		local row_lbl = 5
		foreach v of varlist $base_vars8 {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
			local row_lbl = `row_lbl' + 2
		}
		local row_lbl = 12
		foreach v of varlist $pca_vars8 {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
			local row_lbl = `row_lbl' + 2
		}
		local row_lbl = 17
		foreach x in $base_vars8 {
			foreach z in $pca_vars8 {
				local lbl_x : variable label `x'
				local lbl_z : variable label `z'
				putexcel B`row_lbl' = "`lbl_x'*`lbl_z'", txtwrap
				local row_lbl = `row_lbl' + 2
			}
		}
		
		* --- Formatting: Fonts, headers and panels ---
		
		* Font sizes
		putexcel B2:H33, font("Times New Roman", 12)
		putexcel B34:H34, font("Times New Roman", 10)
		
		* Alignment
		putexcel C3:H33, hcenter vcenter
		putexcel B4:B34, vcenter
		
		* --- Headers ---
		putexcel B2:H2 = "Table 8. Baseline results. Armed Conflict and Non-Marital Migration, Individual-level Analysis", merge hcenter border(bottom)
		putexcel B3 = "Dependent Variable: Migration outside household in a given year (yes=1)", txtwrap hcenter vcenter
		putexcel B3:H3, border(bottom, double)

		* --- Regression headers ---
		forvalues i = 1/6 {
			putexcel `=char(`i'+66)'3 = "(`i')",
		}
		
		* Column subtitles
		putexcel B4 = "Conflict exposure, Village level", italic underline
		putexcel B11 = "Conflict exposure, Household level", italic underline
		putexcel B16 = "Interactions", italic underline
		
		* --- Summary stats labels ---
		putexcel B11:H11, border(top)
		putexcel B16:H16, border(top)
		putexcel B29:H29, border(top)
		putexcel B29 = "Observations", italic
		putexcel B30 = "Mean Dependent Variable", italic
		putexcel B31 = "Individual Fixed Effect", italic
		putexcel B32 = "Year Fixed Effect", italic
		putexcel B33 = "Province time-trend", italic
		
		forvalues i = 3/8 {
			putexcel `=char(`i'+64)'31 = "Yes", italic
			putexcel `=char(`i'+64)'32 = "Yes", italic
			putexcel `=char(`i'+64)'33 = "Yes", italic
		}

		* --- Footnote ---
		putexcel B34:H34= ///
		"Notes - This table presents our baseline regression for non-marital migration at individual level. Robust standard errors, clustered at Village level. * p<0.10  ** p<0.05 *** p<0.01. The dependent variable, Migration outside of the household in a given year (yes=1) takes value one when a person migrates due to non-marital reasons in a given year. Sample includes all household members that either never migrate or migrate for non-marital reasons during 1998-2007. Violence in a given year (presence=1)   takes value one when the number of casualties in a given year is positive, 0 otherwise. Number of casualties in a given year includes the number of individuals killed or wounded in a given year, divided by 100 people. Index of Asset Related Losses refers - PCA -  refers to the first component from a Principal Component Analysis for Theft of money (yes=1), Theft or destruction of goods (yes=1), and Destruction of house (yes=1)  for a household in a given year.  Data Source: 2007 Burundi Priority Panel Survey. Data Source: 2007 Burundi Priority Panel Survey.", ///
		merge txtwrap border(top)

		* --- Format with xl() ---
		mata
			b = xl()
			b.load_book("$results")
			b.set_sheet("Table 8")
			// Remove gridlines and set background white
			b.set_sheet_gridlines("Table 8", "off")
			// Column widths
			b.set_column_width(2,2,87)
			b.set_column_width(3,12,14)
			// Row heights
			b.set_row_height(3, 3, 50)
			b.set_row_height(4, 4, 25)
			b.set_row_height(11, 11, 25)
			b.set_row_height(16, 16, 25)
			b.set_row_height(21, 21, 30)
			b.set_row_height(25, 25, 30)
			b.set_row_height(27, 27, 30)
			b.set_row_height(34, 34, 80)
			b.close_book()
		end

* --- --- --- --- --- --- --- --- --- --- --- --- ---
* TABLE IX
* --- --- --- --- --- --- --- --- --- --- --- --- ---

		* --- Variables to interact ---
		global base_vars9 "deathwounded_abovemean"
		global pca_vars9 "pca_all_abovemean"
		
		* Run regressions and store
		eststo clear
		local count = 1
		foreach sample in "if sex==1" "if sex==0" "if adult_18==1" "if adult_18==0" "if pov_stat98==1" "if pov_stat98==0" {
			qui xtreg leave c.deathwounded_abovemean##c.pca_all_abovemean i.year province_trend `sample', cluster(reczd) fe 
				eststo model_`count'
				qui summarize leave if e(sample)
				qui estadd scalar depmean = r(mean)
				local ++count
		}
		
		* Set sheet
		putexcel set "$results", sheet("Table 9") modify
		
		local col = 3   
		local row = 6  
		local row_s = 14
		
		forvalues i = 1/6 {
			
			* --- Restore current model ---
			est restore model_`i'
			
			* Identify variables
			local vvar = "c.deathwounded_abovemean"
			local zvar = "c.pca_all_abovemean"
			local interaction = "c.`vvar'#c.`zvar'"

			* --- Extract estimates ---
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
			
			scalar bi = _b[`interaction']
			scalar sei = _se[`interaction']
			scalar p_i = 2*ttail(e(df_r), abs(bi/sei))
			local si = ""
			if p_i < .01 local si = "***"
			else if p_i < .05 local si = "**"
			else if p_i < .10 local si = "*"
			
			scalar depm = e(depmean)
			scalar obs  = e(N)
			
			* --- Format values ---
			local bvfmt = string(bv, "%9.3f")
			local sevfmt = string(se_v, "%9.3f")
			local bzfmt = string(bz, "%9.3f")
			local sezfmt = string(sez, "%9.3f")
			local bifmt = string(bi, "%9.3f")
			local seifmt = string(sei, "%9.3f")
			local depm    = string(depm, "%9.3f")  
			local obs     = string(obs, "%9.0f") 

			* --- Export coefficient and standar error with stars ---
			putexcel `=char(`col'+64)'`row' = ("`bvfmt'`sv'")
			putexcel `=char(`col'+64)'`=`row'+1' = ("[`sevfmt']")
			putexcel `="B" + string(`row'+1) + ":H" + string(`row'+1)' , border(bottom, dotted)
			
			putexcel `=char(`col'+64)'`=`row'+3' = ("`bzfmt'`sz'")
			putexcel `=char(`col'+64)'`=`row'+4' = ("[`sezfmt']")
			putexcel `="B" + string(`row'+4) + ":H" + string(`row'+4)' , border(bottom, dotted)
			
			putexcel `=char(`col'+64)'`=`row'+6' = ("`bifmt'`si'")
			putexcel `=char(`col'+64)'`=`row'+7' = ("[`seifmt']")
			putexcel `="B" + string(`row'+7) + ":H" + string(`row'+7)' , border(bottom, dotted)
			
			* --- Export regression statistics below the table ---
			putexcel `=char(`col'+64)'`row_s' = `obs', overwrite italic
			local row_s1=`row_s'+1
			putexcel `=char(`col'+64)'`row_s1' = `depm', overwrite italic
			
			* Update  column
			local col = `col' + 1
		}
		
		* Write variable labels
		local row_lbl = 6
		foreach v of varlist $base_vars9 {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
		}
		local row_lbl = 9
		foreach v of varlist $pca_vars9 {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
		}
		local row_lbl = 12
		foreach x in $base_vars6 {
			foreach z in $pca_vars6 {
				local lbl_x : variable label `x'
				local lbl_z : variable label `z'
				putexcel B`row_lbl' = "`lbl_x'*`lbl_z'", txtwrap
			}
		}
		
		* --- Formatting: Fonts, headers and panels ---
		
		* Font sizes
		putexcel B2:H18, font("Times New Roman", 12)
		putexcel B19:H19, font("Times New Roman", 10)
		
		* Alignment
		putexcel C3:H18, hcenter vcenter
		putexcel B4:B19, vcenter
		
		* --- Headers ---
		putexcel B2:H2 = "Table 9. Baseline results. Armed Conflict and Migration, Individual-level Analysis", merge hcenter border(bottom)
		putexcel B3:B4 = "Dependent Variable: Migration outside household in a given year (yes=1)", txtwrap hcenter vcenter merge
		putexcel C3 = "Only women", txtwrap
		putexcel D3 = "Only men", txtwrap
		putexcel E3 = "Adults (older than 18 years old)", txtwrap
		putexcel F3 = "Children (younger than 18 years old)", txtwrap
		putexcel G3 = "Poor Households (1998)", txtwrap
		putexcel H3 = "Non-Poor Households (1998)", txtwrap
		putexcel B4:H4, border(bottom, double)

		* --- Regression headers ---
		forvalues i = 1/6 {
			putexcel `=char(`i'+66)'4 = "(`i')",
		}
		
		* Column subtitles
		putexcel B5 = "Conflict exposure, Village level", italic underline bold
		putexcel B8 = "Conflict exposure, Household level", italic underline bold
		putexcel B11 = "Interaction effect", italic underline bold

		* --- Summary stats labels ---
		putexcel B14:H14, border(top)
		putexcel B14 = "Observations", italic
		putexcel B15 = "Mean Dependent Variable", italic
		putexcel B16 = "Individual Fixed Effect", italic
		putexcel B17 = "Year Fixed Effect", italic
		putexcel B18 = "Province time-trend", italic
		
		forvalues i = 3/8 {
			putexcel `=char(`i'+64)'16 = "Yes", italic
			putexcel `=char(`i'+64)'17 = "Yes", italic
			putexcel `=char(`i'+64)'18 = "Yes", italic
		}
		
		* --- Footnote ---
		putexcel B19:H19 = ///
		"Notes - This table presents our heterogeneity analysis for non-marital migration at individual level. Robust standard errors, clustered at VIllage level. * p<0.10  ** p<0.05 *** p<0.01. The dependent variable, Migration outside of the household in a given year (yes=1) takes value one when a person migrates in a given year. Columns (1) to (4) restricts the baseline sample to only women, only men, only adults (older than 18 years old) or only young (younger than 18 years old), respectively. Columns (5) and (6) split the baseline sample defining poverty based on the 1997 national Burundi poverty line. Violence in a given year (presence=1)   takes value one when the number of casualties in a given year is positive, 0 otherwise. Number of casualties in a given year includes the number of individuals killed or wounded in a given year, divided by 100 people.Index of Asset Related Losses refers - PCA -  refers to the first component from a Principal Component Analysis for Theft of money (yes=1), Theft or destruction of goods (yes=1), and Destruction of house (yes=1)  for a household in a given year.  Data Source: 2007 Burundi Priority Panel Survey.", ///
		merge txtwrap border(top)

		* --- Format with xl() ---
		mata
			b = xl()
			b.load_book("$results")
			b.set_sheet("Table 9")
			// Remove gridlines and set background white
			b.set_sheet_gridlines("Table 9", "off")
			// Column widths
			b.set_column_width(2,2,70)
			b.set_column_width(3,12,15)
			// Row heights
			b.set_row_height(3, 3, 50)
			b.set_row_height(5, 5, 25)
			b.set_row_height(8, 8, 25)
			b.set_row_height(11, 11, 25)
			b.set_row_height(12, 12, 30)
			b.set_row_height(19, 19, 90)
			b.close_book()
		end
		

* --- --- --- --- --- --- --- --- --- --- --- --- ---
* TABLE X
* --- --- --- --- --- --- --- --- --- --- --- --- ---

		* Generate lags
		gen lag_deathwounded_abovemean = L1.deathwounded_abovemean
		gen lag_pca_all_abovemean = L1.pca_all_abovemean
	
		* --- Variables to interact ---
		global base_vars10 "d_violence deathwounded_100 deathwounded_abovemean"
		global pca_vars10 "pca_all_abovemean pca_all"

		* Run regressions and store
		eststo clear
		local count = 1
		foreach x in $base_vars10 {
			foreach z in $pca_vars10 {
				 xtreg leave c.`x'##c.`z' c.lag_`x'##c.lag_`z' i.year province_trend, fe cluster(reczd)
				eststo model_`count'
				qui summarize leave if e(sample)
				qui estadd scalar depmean = r(mean)
				local ++count
			}
		}
		
		* Set sheet
		putexcel set "$results", sheet("Table 10") modify
		
		local col = 3   
		local row = 5   
		local row_pca_start = 18
		local row_int_start = 27
		local row_s = 51 
		
		forvalues i = 1/6 {
			
			* --- Restore current model ---
			est restore model_`i'
			
			* Identify variables
			local x = e(cmdline)
			
			foreach v in $base_vars10 {
				if strpos("`x'", "`v'") local vvar = "`v'"
			}
			foreach z in $pca_vars10 {
				if strpos("`x'", "`z'") local zvar = "`z'"
			}
			
			local interaction = "c.`vvar'#c.`zvar'"
			local lag_vvar = "lag_`vvar'"
			local lag_zvar = "lag_`zvar'"
			local lag_interaction = "c.lag_`vvar'#c.lag_`zvar'"

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
			
			scalar bi = _b[`interaction']
			scalar sei = _se[`interaction']
			scalar p_i = 2*ttail(e(df_r), abs(bi/sei))
			local si = ""
			if p_i < .01 local si = "***"
			else if p_i < .05 local si = "**"
			else if p_i < .10 local si = "*"
			
			scalar blagi = _b[`lag_interaction']
			scalar selagi = _se[`lag_interaction']
			scalar p_lagi = 2*ttail(e(df_r), abs(blagi/selagi))
			local slagi = ""
			if p_lagi < .01 local slagi = "***"
			else if p_lagi < .05 local slagi = "**"
			else if p_lagi < .10 local slagi = "*"
			
			* --- Format values ---
			local bvfmt = string(bv, "%9.3f")
			local sevfmt = string(se_v, "%9.3f")
			local blagvfmt = string(blagv, "%9.3f")
			local selagvfmt = string(se_lagv, "%9.3f")
			local bzfmt = string(bz, "%9.3f")
			local sezfmt = string(sez, "%9.3f")
			local blagzfmt = string(blagz, "%9.3f")
			local selagzfmt = string(selagz, "%9.3f")
			local bifmt = string(bi, "%9.3f")
			local seifmt = string(sei, "%9.3f")
			local blagifmt = string(blagi, "%9.3f")
			local selagifmt = string(selagi, "%9.3f")
			local depm    = string(depm, "%9.3f")  
			local obs     = string(obs, "%9.0f")  

			* --- Export coefficient and standar error with stars ---
			putexcel `=char(`col'+64)'`row' = ("`bvfmt'`sv'")
			putexcel `=char(`col'+64)'`=`row'+1' = ("[`sevfmt']")
			putexcel `=char(`col'+64)'`=`row'+2' = ("`blagvfmt'`slagv'")
			putexcel `=char(`col'+64)'`=`row'+3' = ("[`selagvfmt']")

			if inlist(`i', 2, 4, 6) {
				local row_pca_start = `row_pca_start' + 4
			}
			else if inlist(`i', 3, 5) {
				local row_pca_start = `row_pca_start' - 4
			}

			local row_z = `row_pca_start'
			putexcel `=char(`col'+64)'`row_z' = ("`bzfmt'`sz'")
			putexcel `=char(`col'+64)'`=`row_z'+1' = ("[`sezfmt']")
			putexcel `=char(`col'+64)'`=`row_z'+2' = ("`blagzfmt'`slagz'")
			putexcel `=char(`col'+64)'`=`row_z'+3' = ("[`selagzfmt']")

			putexcel `=char(`col'+64)'`row_int_start' = ("`bifmt'`si'")
			putexcel `=char(`col'+64)'`=`row_int_start'+1' = ("[`seifmt']")
			putexcel `=char(`col'+64)'`=`row_int_start'+2' = ("`blagifmt'`slagi'")
			putexcel `=char(`col'+64)'`=`row_int_start'+3' = ("[`selagifmt']")
			
			local row_int_start = `row_int_start' + 4
			
			* --- Export regression statistics below the table ---
			putexcel `=char(`col'+64)'`row_s' = `obs', overwrite italic
			local row_s1=`row_s'+1
			putexcel `=char(`col'+64)'`row_s1' = `depm', overwrite italic
			
			* Update row and column
			if inlist(`i', 2, 4) {
				local row = `row' + 4
			}
				
			local col = `col' + 1
		}
		
		* Write variable labels
		local row_lbl = 5
		foreach v of varlist $base_vars10 {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
			local row_lbl = `row_lbl' + 2
			putexcel B`row_lbl' = "Lag `lbl'"
			local row_lbl = `row_lbl' + 2
		}
		local row_lbl = 18
		foreach v of varlist $pca_vars10 {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
			local row_lbl = `row_lbl' + 2
			putexcel B`row_lbl' = "Lag `lbl'"
			local row_lbl = `row_lbl' + 2
		}
		local row_lbl = 27
		foreach x in $base_vars10 {
			foreach z in $pca_vars10 {
				local lbl_x : variable label `x'
				local lbl_z : variable label `z'
				putexcel B`row_lbl' = "`lbl_x'*`lbl_z'", txtwrap
				local row_lbl = `row_lbl' + 2
				putexcel B`row_lbl' = "Lag `lbl_x'*Lag `lbl_z'", txtwrap
				local row_lbl = `row_lbl' + 2
			}
		}
		
		* --- Formatting: Fonts, headers and panels ---
		
		* Font sizes
		putexcel B2:H55, font("Times New Roman", 12)
		putexcel B56:H56, font("Times New Roman", 10)
		
		* Alignment
		putexcel C3:H55, hcenter vcenter
		putexcel B4:B56, vcenter
		
		* --- Headers ---
		putexcel B2:H2 = "Table 10. Armed Conflict and Non-Marital Migration using lags, Individual-level Analysis", merge hcenter border(bottom)
		putexcel B3 = "Dependent Variable: Migration outside household in a given year (yes=1)", txtwrap hcenter vcenter
		putexcel B3:H3, border(bottom, double)

		* --- Regression headers ---
		forvalues i = 1/6 {
			putexcel `=char(`i'+66)'3 = "(`i')",
		}
		
		* Column subtitles
		putexcel B4 = "Conflict exposure, Village level", italic underline
		putexcel B17 = "Conflict exposure, Household level", italic underline
		putexcel B26 = "Interactions", italic underline
		
		* --- Summary stats labels ---
		putexcel B17:H17, border(top)
		putexcel B26:H26, border(top)
		putexcel B51:H51, border(top)
		putexcel B51 = "Observations", italic
		putexcel B52 = "Mean Dependent Variable", italic
		putexcel B53 = "Individual Fixed Effect", italic
		putexcel B54 = "Year Fixed Effect", italic
		putexcel B55 = "Province time-trend", italic
		
		forvalues i = 3/8 {
			putexcel `=char(`i'+64)'53 = "Yes", italic
			putexcel `=char(`i'+64)'54 = "Yes", italic
			putexcel `=char(`i'+64)'55 = "Yes", italic
		}

		* --- Footnote ---
		putexcel B56:H56= ///
		"Notes - This table presents our baseline regression for non-marital migration at individual level. Robust standard errors, clustered at VIllage level. * p<0.10  ** p<0.05 *** p<0.01. The dependent variable, Migration outside of the household in a given year (yes=1) takes value one when a person migrates due to non-marital reasons in a given year. Sample includes all household members that either never migrate or migrate for non-marital reasons during 1998-2007. Violence in a given year (presence=1)   takes value one when the number of casualties in a given year is positive, 0 otherwise. Number of casualties in a given year includes the number of individuals killed or wounded in a given year, divided by 100 people. Index of Asset Related Losses refers - PCA -  refers to the first component from a Principal Component Analysis for Theft of money (yes=1), Theft or destruction of goods (yes=1), and Destruction of house (yes=1)  for a household in a given year.  Data Source: 2007 Burundi Priority Panel Survey. Data Source: 2007 Burundi Priority Panel Survey", ///
		merge txtwrap border(top)

		* --- Format with xl() ---
		mata
			b = xl()
			b.load_book("$results")
			b.set_sheet("Table 10")
			// Remove gridlines and set background white
			b.set_sheet_gridlines("Table 10", "off")
			// Column widths
			b.set_column_width(2,2,87)
			b.set_column_width(3,12,14)
			// Row heights
			b.set_row_height(3, 3, 50)
			b.set_row_height(4, 4, 25)
			b.set_row_height(17, 17, 25)
			b.set_row_height(26, 26, 25)
			b.set_row_height(29, 29, 30)
			b.set_row_height(35, 35, 30)
			b.set_row_height(37, 37, 30)
			b.set_row_height(43, 43, 30)
			b.set_row_height(45, 45, 30)
			b.set_row_height(47, 47, 30)
			b.set_row_height(49, 49, 30)
			b.set_row_height(56, 56, 90)
			b.close_book()
		end
		
* --- --- --- --- --- --- --- --- --- --- --- --- ---
* TABLE XI
* --- --- --- --- --- --- --- --- --- --- --- --- ---

		* --- Variables to interact ---
		global base_vars11 "deathwounded_abovemean"
		global pca_vars11 "pca_all_abovemean"
		
		* Run regressions and store
		eststo clear
		local count = 1
		foreach sample in "if sex==1" "if sex==0" "if adult_18==1" "if adult_18==0" "if pov_stat98==1" "if pov_stat98==0" {
			qui xtreg leave c.deathwounded_abovemean##c.pca_all_abovemean c.lag_deathwounded_abovemean##c.lag_pca_all_abovemean i.year province_trend `sample', cluster(reczd) fe 
				eststo model_`count'
				qui summarize leave if e(sample)
				qui estadd scalar depmean = r(mean)
				local ++count
		}
		
		* Set sheet
		putexcel set "$results", sheet("Table 11") modify
		
		local col = 3   
		local row = 6  
		local row_s = 20
		
		forvalues i = 1/6 {
			
			* --- Restore current model ---
			est restore model_`i'
			
			* Identify variables
			local vvar = "c.deathwounded_abovemean"
			local zvar = "c.pca_all_abovemean"
			local interaction = "c.deathwounded_abovemean#c.pca_all_abovemean"
			local lag_vvar = "c.lag_deathwounded_abovemean"
			local lag_zvar = "c.lag_pca_all_abovemean"
			local lag_interaction = "c.lag_deathwounded_abovemean#c.lag_pca_all_abovemean"

			* --- Extract estimates ---
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
			
			scalar bi = _b[`interaction']
			scalar sei = _se[`interaction']
			scalar p_i = 2*ttail(e(df_r), abs(bi/sei))
			local si = ""
			if p_i < .01 local si = "***"
			else if p_i < .05 local si = "**"
			else if p_i < .10 local si = "*"
			
			scalar blagi = _b[`lag_interaction']
			scalar selagi = _se[`lag_interaction']
			scalar p_lagi = 2*ttail(e(df_r), abs(blagi/selagi))
			local slagi = ""
			if p_lagi < .01 local slagi = "***"
			else if p_lagi < .05 local slagi = "**"
			else if p_lagi < .10 local slagi = "*"
			
			scalar depm = e(depmean)
			scalar obs  = e(N)
			
			* --- Format values ---
			local bvfmt = string(bv, "%9.3f")
			local sevfmt = string(se_v, "%9.3f")
			local blagvfmt = string(blagv, "%9.3f")
			local selagvfmt = string(se_lagv, "%9.3f")
			local bzfmt = string(bz, "%9.3f")
			local sezfmt = string(sez, "%9.3f")
			local blagzfmt = string(blagz, "%9.3f")
			local selagzfmt = string(selagz, "%9.3f")
			local bifmt = string(bi, "%9.3f")
			local seifmt = string(sei, "%9.3f")
			local blagifmt = string(blagi, "%9.3f")
			local selagifmt = string(selagi, "%9.3f")
			local depm    = string(depm, "%9.3f")  
			local obs     = string(obs, "%9.0f")  

			* --- Export coefficient and standar error with stars ---
			putexcel `=char(`col'+64)'`row' = ("`bvfmt'`sv'")
			putexcel `=char(`col'+64)'`=`row'+1' = ("[`sevfmt']")
			putexcel `=char(`col'+64)'`=`row'+2' = ("`blagvfmt'`slagv'")
			putexcel `=char(`col'+64)'`=`row'+3' = ("[`selagvfmt']")
			putexcel `="B" + string(`row'+3) + ":H" + string(`row'+3)' , border(bottom, dotted)
			
			putexcel `=char(`col'+64)'`=`row'+5' = ("`bzfmt'`sz'")
			putexcel `=char(`col'+64)'`=`row'+6' = ("[`sezfmt']")
			putexcel `=char(`col'+64)'`=`row_z'+7' = ("`blagzfmt'`slagz'")
			putexcel `=char(`col'+64)'`=`row_z'+8' = ("[`selagzfmt']")
			putexcel `="B" + string(`row'+8) + ":H" + string(`row'+8)' , border(bottom, dotted)
			
			putexcel `=char(`col'+64)'`=`row'+10' = ("`bifmt'`si'")
			putexcel `=char(`col'+64)'`=`row'+11' = ("[`seifmt']")
			putexcel `=char(`col'+64)'`=`row_int_start'+12' = ("`blagifmt'`slagi'")
			putexcel `=char(`col'+64)'`=`row_int_start'+13' = ("[`selagifmt']")
			putexcel `="B" + string(`row'+13) + ":H" + string(`row'+13)' , border(bottom, dotted)
			
			* --- Export regression statistics below the table ---
			putexcel `=char(`col'+64)'`row_s' = `obs', overwrite italic
			local row_s1=`row_s'+1
			putexcel `=char(`col'+64)'`row_s1' = `depm', overwrite italic
			
			* Update  column
			local col = `col' + 1
		}
		
		* Write variable labels
		local row_lbl = 6
		foreach v of varlist $base_vars11 {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
			local row_lbl = `row_lbl' + 2
			putexcel B`row_lbl' = "Lag `lbl'"
		}
		local row_lbl = 11
		foreach v of varlist $pca_vars11 {
			local lbl : variable label `v'
			putexcel B`row_lbl' = "`lbl'"
			local row_lbl = `row_lbl' + 2
			putexcel B`row_lbl' = "Lag `lbl'"
		}
		local row_lbl = 16
		foreach x in $base_vars11 {
			foreach z in $pca_vars11 {
				local lbl_x : variable label `x'
				local lbl_z : variable label `z'
				putexcel B`row_lbl' = "`lbl_x'*`lbl_z'", txtwrap
				local row_lbl = `row_lbl' + 2
				putexcel B`row_lbl' = "Lag `lbl_x'*Lag `lbl_z'", txtwrap
			}
		}
		
		* --- Formatting: Fonts, headers and panels ---
		
		* Font sizes
		putexcel B2:H24, font("Times New Roman", 12)
		putexcel B25:H25, font("Times New Roman", 10)
		
		* Alignment
		putexcel C3:H24, hcenter vcenter
		putexcel B4:B25, vcenter
		
		* --- Headers ---
		putexcel B2:H2 = "Table 11. Armed Conflict and Non-Marital Migration using lags, Individual-level Analysi", merge hcenter border(bottom)
		putexcel B3:B4 = "Dependent Variable: Migration outside household in a given year (yes=1)", txtwrap hcenter vcenter merge
		putexcel C3 = "Only women", txtwrap
		putexcel D3 = "Only men", txtwrap
		putexcel E3 = "Adults (older than 18 years old)", txtwrap
		putexcel F3 = "Children (younger than 18 years old)", txtwrap
		putexcel G3 = "Poor Households (1998)", txtwrap
		putexcel H3 = "Non-Poor Households (1998)", txtwrap
		putexcel B4:H4, border(bottom, double)

		* --- Regression headers ---
		forvalues i = 1/6 {
			putexcel `=char(`i'+66)'4 = "(`i')",
		}
		
		* Column subtitles
		putexcel B5 = "Conflict exposure, Village level", italic underline bold
		putexcel B10 = "Conflict exposure, Household level", italic underline bold
		putexcel B15 = "Interaction effect", italic underline bold

		* --- Summary stats labels ---
		putexcel B20:H20, border(top)
		putexcel B20 = "Observations", italic
		putexcel B21 = "Mean Dependent Variable", italic
		putexcel B22 = "Individual Fixed Effect", italic
		putexcel B23 = "Year Fixed Effect", italic
		putexcel B24 = "Province time-trend", italic
		
		forvalues i = 3/8 {
			putexcel `=char(`i'+64)'22 = "Yes", italic
			putexcel `=char(`i'+64)'23 = "Yes", italic
			putexcel `=char(`i'+64)'24 = "Yes", italic
		}
		
		* --- Footnote ---
		putexcel B25:H25 = ///
		"Notes - This table presents our heterogeneity analysis for non-marital migration at individual level. Robust standard errors, clustered at Village level. * p<0.10  ** p<0.05 *** p<0.01. The dependent variable, Migration outside of the household in a given year (yes=1) takes value one when a person migrates in a given year. Columns (1) to (4) restricts the baseline sample to only women, only men, only adults (older than 18 years old) or only young (younger than 18 years old), respectively. Columns (5) and (6) split the baseline sample defining poverty based on the 1997 national Burundi poverty line. Violence in a given year (presence=1)   takes value one when the number of casualties in a given year is positive, 0 otherwise. Number of casualties in a given year includes the number of individuals killed or wounded in a given year, divided by 100 people.Index of Asset Related Losses refers - PCA -  refers to the first component from a Principal Component Analysis for Theft of money (yes=1), Theft or destruction of goods (yes=1), and Destruction of house (yes=1)  for a household in a given year.  Data Source: 2007 Burundi Priority Panel Survey.", ///
		merge txtwrap border(top)

		* --- Format with xl() ---
		mata
			b = xl()
			b.load_book("$results")
			b.set_sheet("Table 11")
			// Remove gridlines and set background white
			b.set_sheet_gridlines("Table 11", "off")
			// Column widths
			b.set_column_width(2,2,70)
			b.set_column_width(3,12,15)
			// Row heights
			b.set_row_height(3, 3, 50)
			b.set_row_height(5, 5, 25)
			b.set_row_height(10, 10, 25)
			b.set_row_height(15, 15, 25)
			b.set_row_height(16, 16, 30)
			b.set_row_height(18, 18, 30)
			b.set_row_height(25, 25, 90)
			b.close_book()
		end
		
		
