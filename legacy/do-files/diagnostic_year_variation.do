* --- --- --- --- --- --- --- --- --- 
* Diagnostic: Verify Year Variation in Dependent Variables
* --- --- --- --- --- --- --- --- --- 

* Load and prepare data
global path_work "/Users/jmunozm1/Documents/GitHub/household_structure_burundi/"
run "do-files/00_DataPreliminaries_Akresh-etal_2025.do"

* Apply same sample restrictions
keep if numsplit==0
drop if age==.
drop age
gen age=year-born_year_07
drop if Code98==.

keep if restr_7==1

xtset id_person year
bys province year: gen province_trend=_n

merge m:1 id_hh year using "$path_work/data/job/pca.dta", nogen

rename year jaar
merge m:1 reczd numen numsplit pid07 jaar using "$path_work/data/origin/demofinal17.dta", keepusing(totexp_a98 TOTEXP_mae07 litm98) keep(1 3) nogen
rename jaar year

* Create migration variables (same as in main file)
replace leave = 0 if missing(leave)

gen leave_adult  = (leave == 1 & adult_18 == 1) 
gen leave_child = (leave == 1 & adult_18 == 0) 
gen leave_woman = (leave == 1 & sex == 1) 
gen leave_man = (leave == 1 & sex == 0) 

local migration leave leave_adult leave_child leave_woman leave_man

bys id_hh year: gen hh_size = _N

egen woman_size = total(sex==1), by(id_hh year)
egen man_size = total(sex==0), by(id_hh year)
egen child_size = total(adult_18==0), by(id_hh year)
egen adult_size = total(adult_18==1), by(id_hh year)

bys id_hh: egen max_child_size = max(child_size)
bys id_hh: egen max_adult_size = max(adult_size)

foreach v of local migration {
	bys id_hh year: egen any_`v' = max(`v')
	bys id_hh year: egen total_`v'_year = total(`v')
	gen share_`v' = .
	if      inlist("`v'","leave")                    replace share_`v' = total_`v'_year/hh_size
	else if inlist("`v'","leave_adult","mig_adult")  replace share_`v' = total_`v'_year/adult_size 
	else if inlist("`v'","leave_child","mig_child")  replace share_`v' = total_`v'_year/child_size
	else if inlist("`v'","leave_woman","mig_woman")  replace share_`v' = total_`v'_year/woman_size 
	else if inlist("`v'","leave_man","mig_man")      replace share_`v' = total_`v'_year/man_size 
	replace share_`v' = 0 if missing(share_`v')
}

* --- --- --- --- --- --- --- --- --- 
* DIAGNOSTIC: Check Variation
* --- --- --- --- --- --- --- --- --- 

display "=========================================="
display "DIAGNOSTIC: Year Variation in Dependent Variables"
display "=========================================="

* Check variation within household
local depvars "any_leave any_leave_adult any_leave_child any_leave_man any_leave_woman share_leave share_leave_adult share_leave_child share_leave_man share_leave_woman"

foreach var in $depvars {
	display ""
	display "Variable: `var'"
	display "-----------"
	
	* For each household, check if variable changes across years
	bys id_hh: gen min_`var' = min(`var')
	bys id_hh: gen max_`var' = max(`var')
	gen flag_`var' = (min_`var' != max_`var')
	
	* Count households with variation
	tabulate flag_`var', missing
	
	* Show summary stats
	sum `var', detail
	
	cap drop min_`var' max_`var' flag_`var'
}

display ""
display "=========================================="
display "INTERPRETATION:"
display "If flag_`var'=0 has almost all observations,"
display "  → Variables do NOT vary by year → Need different approach"
display "If flag_`var'=1 has many observations,"
display "  → Variables DO vary by year → Regression should work!"
display "=========================================="
