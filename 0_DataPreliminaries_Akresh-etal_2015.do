*--------------------------------------------*
*---- Civil War and Household Composition ---*
*------ Akresh, Verwimp and Muñoz (2015) ----*
*-------- Data Preliminaries ----------------*
*--------------------------------------------*

 global path_work "/path/where/data/and/dofiles/are/located"
 
*--- Initial

  cap restore
  clear all
  *set mem 2g
  set more off
  set logtype smcl
  set matsize 8000
  pause on
  set type double, permanently
  set type float, permanently



*--- Open Data 

  use "$path_work/data/final/panel_individual.dta", clear


*--- Data preparation

    *-- 0 -  Gen ID by person
      egen id_person=concat(reczd numen numsplit pid07)
      egen id_hh=concat(reczd numen)
      destring id_person id_hh, replace
      xi i.year
      xtset id_person year 

    *-- 1 -  Generating variables 
      cap drop log_coffe deathwounded_100 lag_deathwounded_100
      gen log_coffe=log(cff_income+1)
      gen deathwounded_100=deathwounded/100 
      gen lag_deathwounded_100=lag_deathwounded/100 

      foreach i in sk_nt_rain sk_nt_drought sk_nt_disease sk_nt_crop_good sk_nt_crop_bad sk_nt_destru_rain sk_nt_erosion sk_vl_rob_money sk_vl_rob_product sk_vl_rob_goods sk_vl_rob_destruction sk_vl_rob_land sk_ec_input_access sk_ec_input_price sk_ec_nonmarket sk_ec_output_price sk_ec_sell_land sk_ec_sell_other sk_ec_rec_help {
        replace `i'=0 if `i'==.
        }

    *-- 3 - Group age
       cap drop adult_15 adult_18
        gen adult_15=(age>=15)
        gen adult_18=(age>=18)

*-- Different Samples

    * The list of the migration is:   
    *1) All sample - 
    *2) Permanent and without migration - 
    *3) Transitory and without migration 
    *4) Permanent and transitory - 
    *5) Marriage and without migration - 
    *6) Only marriage
    * 7) All without marriage */
    gen restr_1=1
    local u=2
    foreach h in "type_people==1|type_people==3" "type_people==2|type_people==3" "type_people==1|type_people==2" "type_people==1&mig_why==3|type_people==3" "type_people==1&mig_why==3" "mig_why!=3"  {
      gen restr_`u'=(`h')
      local u=`u'+1
    }

*-- Merge potential instruments 
  sort reczd 
  merge n:1 reczd using "$path_work/data/final/inst.dta",  nogenerate keepusing(altitude_av__m_ rainfall_av__mm_ temp_av)
 
*--- Creating Dependent Variables
  
  qui include "$path_work/do-files/0a_Genvariables_Akresh-etal_2015.do" 

*--- Adding labels

  qui include "$path_work/do-files/labels.do" 

* Merging the poverty status information.
      sort reczd numen
      merge m:1 reczd numen using "$path_work/data/origin/poverty_status98.dta", nogenerate keep(master matched)

      merge m:1 reczd numen using "$path_work/data/origin/poverty_status98-07.dta", nogenerate keep(master matched)

      






      