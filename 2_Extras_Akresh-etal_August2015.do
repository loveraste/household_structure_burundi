*--------------------------------------------*
*---- Civil War and Household Composition ---*
*------ Akresh, Muñoz and Verwimp (2015) ----*
*------     TABLES                        ----*
*------     July 24, 2015                ----*
*--------------------------------------------*
*--------------------------------------------*

* --- --- --- --- --- --- --- --- --- 
* Defining Working Paths  
* --- --- --- --- --- --- --- --- --- 

  global path_work "/path/where/data/and/dofiles/are/located"
  global graphs "/path/where/graphs/are/located"
  global results "/excel/file/where/tables/are/located.xlsx"

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
* Graph 1: Migration experience 
* --- --- --- --- --- --- --- --- --- 
  cap restore
  preserve

    keep if restr_7==1
    variables
    qui include "$path_work/do-files/labels.do" 

  * mig_why - SECB124 , temp_why - SEC46
  keep if type_people==1|type_people==2

  keep year mig_why temp_why id_person type_people

  bys id_person: egen mode_mig_why=mode(mig_why)
  bys id_person: egen mode_temp_why=mode(temp_why)
  collapse (firstnm) mode_mig_why mode_temp_wh (firstnm) type_people, by(id_person)

  gen main_reason=1 if mode_mig_why==2
  replace main_reason=2 if (mode_mig_why==7|mode_temp_why==1) &  main_reason==.

  replace main_reason=3 if mode_temp_why==5 &  main_reason==.

  replace main_reason=4 if mode_temp_why==4 &  main_reason==.


  replace main_reason=5 if (mode_mig_why==4|mode_mig_why==5|mode_mig_why==6|mode_temp_why==2|mode_temp_why==3) &  main_reason==.

  replace main_reason=6 if main_reason==.

  cap lab drop  main_reason 
  label def main_reason 1 "Divorce" 2 "Work" 3 "Famine" 4 "Insecurity" 5 "Conflict Related Reasons" 6 "Other"
  label val main_reason main_reason

  label val mode_mig_why SECB124 
  label val mode_temp_why SEC46

  * Label - Permanent Migration
                *2 Divorce ou sÈparation
                *3 Mariage
             *4 Il/elle s'est rÈfugiÈ (dÈpart ‡ cause de la guerre / conflit)
             *5 IL/elle a rejoint un mouvement armÈ
              *6 Il/elle est en prison
                *7 Pour le travail
             *8 Autres

  *Label - Transitory Migration
                *(OK) 1 Chercher   du travail
             *2 DÈmÈnagement  ‡ un camp de dÈplacement
             *3 TransfÈrÈ dans un camp de regroupement
             *4 InsÈcuritÈ liÈe ‡ la crise autre que camps de dÈplacÈs ou camps de regroupement
             *5 Famine
             *6 Autre (‡ prÈciser)
  restore

* --- --- --- --- --- --- --- --- --- 
* Graph 1: Migration experience 
* --- --- --- --- --- --- --- --- --- 


  cap restore
  preserve

  keep if restr_7==1
  variables
  qui include "$path_work/do-files/labels.do" 

  * Household Level
  cap bys id_hh year: gen hh=_n   
  keep if hh==1
  keep if year==1998
  keep d_leave_hh_t v1_d_violence pov_stat98 Poverty_status_07 Food_Poverty07 Food_Poverty98
  drop pov_stat98 Poverty_status_07
  rename Food_Poverty98 pov_stat98 
  rename Food_Poverty07 Poverty_status_07 

  * Collapse
  gen x=1
  drop if pov_stat98==.|Poverty_status_07==.


  collapse (sum) x, by(pov_stat98 Poverty_status_07 d_leave_hh_t v1_d_violence)

  bys v1_d_violence pov_stat98 d_leave_hh_t : egen total_1=sum(x)
  
  bys v1_d_violence pov_stat98 d_leave_hh_t : gen prop=(x/total_1)*100
  
  keep v1_d_violence d_leave_hh_t pov_stat98  Poverty_status_07 prop
  
  reshape wide prop, i(v1_d_violence d_leave_hh_t pov_stat98) j(Poverty_status_07)
  

  cd "$graphs"

  forvalue i=0/1 {
  graph bar prop0 prop1 if v1_d_violence==`i', over(d_leave_hh_t, label(labsize(vsmall))  relabel(1 `""Non-Individual" "Migration""' 2 `""At least one HH" "member migrated""' )) over(pov_stat98, label(labsize(vsmall)  labcolor(gs6) )  relabel(1 `""Non-Extreme Poor Households" "(1998)""' 2 `""Extreme Poor Households" "(1998)""' ) ) ytitle("%")  blabel(bar, position(inside) format(%9.0f) color(white))  $graph_cofing  bar(1,  color(gs4)    lcolor(gs15))   bar(2,  color(gs12)    lcolor(gs9))   legend( label(1 Non-Extreme Poor (2007)) label(2 Extreme Poor  (2007))) bargap(-20) graphregion(color(white))  ylabel(,labsize(vsmall)) legend( region( style(none)) cols(3)  size(small) forcesize ) stack

  graph export graph_1_`i'.png, replace width(4147) height(2250)
  }


* --- --- --- --- --- --- --- --- --- 
* Graph 2: Marriage Migration and Civil War
* --- --- --- --- --- --- --- --- --- 
* New Sample
            cap restore

          * The sample
          * Women: No marriage at 1998
          * In Marital Age
          keep if sex==1
          drop if civil_98==2
          drop if age<15 & age>65
          variables
          *cap ssc d eclplot

          * Gen Our New Dependent Variable
          gen d_marriage=leave if mig_why==3 
          replace d_marriage=0 if d_marriage==.

          * Women: No marriage at 1998
          local j=1
          forvalue i=20(5)65 {
            gen group_age`j'=(age>=15 & age<=`i')
          bys id_hh year:egen sum_marrige`j'=sum(d_marriage) if  group_age`j'==1
          sort id_hh year sum_marrige`j'
          bys id_hh year: replace sum_marrige`j'=sum_marrige`j'[_n-1] if sum_marrige`j'==.
          bys id_hh year: gen d_hh_marriage`j'=(sum_marrige`j'!=0)
          drop sum_marrige`j'
          local ++j
          }



          ** Regressions
          drop hh
          cap bys id_hh year: gen hh=_n         
          keep if hh==1
          xtset id_hh year
          cap drop province_trendd_hh_marri
		  
          bys province year: gen province_trend=_n


          * Save results
          tempfile file
		  
          local i=1
		  
      forvalue k=20(5)65 {
	  	preserve
        keep if age>=15 & age<=`k'
      qui xtreg d_hh_marriage`i' index_asset i.year province_trend , cluster(reczd) fe
      parmest, norestore 
      keep if parm=="index_asset"
      gen sample=`i'
      capture append using `file'
       save `file', replace
       restore
       local ++i
      }

u `file', clear

label def sample 1 "15-20" 2 "15-25" 3 "15-30" 4 "15-35" 5 "15-40" 6 "15-45" 7 "15-50" 8 "15-55" 9 "15-60" 10 "15-65"
label val sample sample

  cd "$graphs"

twoway (scatter sample estimate , msymbol(none)) (scatter sample estimate,  mcolor(black)  ) (rcap min95 max95 sample, horizontal lpattern(dash)  lcolor(gs9)     ), ylabel(1/10, valuelabel angle(0) labsize(small) ) xlabel(, labsize(small) ) legend(off) ytitle("Civil War and Marital Migration over group ages", size(small) )  xtitle("Point Estimates and confidence interval (95%)", size(small)) graphregion(color(white))  xline(0)

  graph export graph_2.png, replace width(4147) height(2250)


