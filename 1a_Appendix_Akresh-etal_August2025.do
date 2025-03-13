*--------------------------------------------*
*---- Civil War and Household Composition ---*
*------ Akresh, Muñoz and Verwimp (2025) ----*
*------     Appendix TAbles                        ----*
*------     March 12, 2025                ----*
*--------------------------------------------*
*--------------------------------------------*

* --- --- --- --- --- --- --- --- --- 
* Defining Working Paths  
* --- --- --- --- --- --- --- --- --- 

  global path_work "/path/where/data/and/dofiles/are/located"
  global results "/excel/file/where/tables/are/located.xlsx"
 

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


* --- --- --- --- --- --- --- --- --- 
* APPENDIX TABLE I 
*  Civil War and Migration, Household Level Analysis, By Age
* --- --- --- --- --- --- --- --- ---

        *** Sample  
          cap restore
          preserve
          keep if restr_7==1
          variables

          * Identifying young
          gen d_children=(adult_18==0)
          bys id_hh year: egen sum_young=sum(d_children)
          bys id_hh year: gen d_young=(sum_young>0)


        * Adult vs Children
            bys id_hh year: egen extra_2=sum(leave) if adult_18==0
            sort id_hh year extra_2
            bys id_hh year: replace extra_2=extra_2[_n-1] if extra_2==.
            replace extra_2=0 if extra_2==.

            bys id_hh year: egen extra_2a=sum(leave) if adult_18==1
            sort id_hh year extra_2a
            bys id_hh year: replace extra_2a=extra_2a[_n-1] if extra_2a==.
            replace extra_2a=0 if extra_2a==.


        * bys id_hh year: gen hh=_n
            drop hh
            bys id_hh year: gen hh=_n
            keep if hh==1
            xtset id_hh year
            cap cap drop province_trend
            bys province year: gen province_trend=_n



        * Dept variables: Dummy 0/1 if any adult leaves
            gen d_adult=(extra_2a>0)
            rename extra_2 extra_2b
            gen d_child=(extra_2b>0)


        * BASELINE RESULTS 
        * Set of variables for the analysis

                mat beta=J(2,4,0)
                mat se=J(2,4,0) 
                mat n=J(2,4,0)  
                mat mean_dep=J(2,4,0) 
                mat df=J(2,4,0) 

        * Column II: Household Approach - Village exposure 

            local m=1
            foreach i in  d_adult {
                foreach j in  $exposure  $intensity  index_agri index_asset {
                  qui xtreg `i'  `j'  i.year province_trend, cluster(reczd) fe
                  mat beta[1,`m']=_b[`j']
                  mat se[1,`m']=_se[`j']
                  mat n[1,`m']=e(N)
                  mat df[1,`m']=e(df_r)
                  qui su  `i'
                  mat mean_dep[1,`m']=r(mean)
                  local m=`m'+1
                }
              }


            local m=1
            foreach i in  d_child {
                foreach j in  $exposure  $intensity  index_agri index_asset {
                  qui xtreg `i'  `j'  i.year province_trend if d_young==1, cluster(reczd) fe
                  mat beta[2,`m']=_b[`j']
                  mat se[2,`m']=_se[`j']
                  mat n[2,`m']=e(N)
                  mat df[2,`m']=e(df_r)
                  qui su  `i'
                  mat mean_dep[2,`m']=r(mean)
                  local m=`m'+1
                }
              }


        * Exporting Results


          * Gen P-value
              mat p_value=J(2,4,0)  
              forvalue i=1/4 {
                mat p_value[1,`i']=(2 * ttail(df[1,`i'], abs(beta[1,`i']/se[1,`i'])))
                mat p_value[2,`i']=(2 * ttail(df[2,`i'], abs(beta[2,`i']/se[2,`i'])))
              }

              
          * Gen Stars 

              forvalue i=1/4 {

                * P-value
                local p_value=p_value[1,`i']

                  if `p_value'>0.1 {
              local beta`i'  : display  "0" int(beta[1,`i']*1000)/1000 
              }

                    if `p_value'<=0.1 & `p_value'>0.05 {
              local beta`i'  : display "0" int(beta[1,`i']*1000)/1000  "*"
              }

              if `p_value'<=0.05  & `p_value'>0.01 {
              local beta`i'  : display "0" int(beta[1,`i']*1000)/1000  "**"
              }

              if `p_value'<=0.01 {
              local beta`i'  : display  "0" int(beta[1,`i']*1000)/1000  "***"
              }

            

              * P-value
                local p_value=p_value[2,`i']
                
                if `p_value'>0.1 {
              local beta1`i'  : display  "0" int(beta[2,`i']*1000)/1000 
              }

                    if `p_value'<=0.1 & `p_value'>0.05 {
              local beta1`i'  : display "0" int(beta[2,`i']*1000)/1000  "*"
              }

              if `p_value'<=0.05  & `p_value'>0.01 {
              local beta1`i'  : display "0" int(beta[2,`i']*1000)/1000  "**"
              }

              if `p_value'<=0.01 {
              local beta1`i'  : display  "0" int(beta[2,`i']*1000)/1000  "***"
              }
              
              }


          * Gen Std.Errors

              forvalue i=1/4 {
                local sd1=se[1,`i']
                local sd2=se[2,`i']
              local sd1_`i'  : display "[0"  int(`sd1'*1000)/1000  "]"
              local sd2_`i'  : display "[0"  int(`sd2'*1000)/1000  "]"
              }

          * Export Results
			  putexcel set "${results}", modify sheet("Appendix Table 1") 
              putexcel C6=("`beta1'") C7=("`sd1_1'")  D9=("`beta2'") D10=("`sd1_2'") E12=("`beta3'") E13=("`sd1_3'") F14=("`beta4'") F15=("`sd1_4'") G6=("`beta11'") G7=("`sd2_1'") H9=("`beta12'") H10=("`sd2_2'") I12=("`beta13'") I13=("`sd2_3'") J14=("`beta14'") J15=("`sd2_4'") 


                mat obs=J(1,8,0)
                mat dep_y=J(1,8,0)
                forvalue i=1/4 {
                  local j=`i'+4
                   mat obs[1,`i'] = n[1,`i']
                   mat obs[1,`j'] = n[2,`i']
                   mat dep_y[1,`i'] = mean_dep[1,`i']
                   mat dep_y[1,`j'] = mean_dep[2,`i']
                }
             
              * Mean and observation
              putexcel C16=matrix(obs) C17=matrix(dep_y)

* --- --- --- --- --- --- --- --- --- 
* APPENDIX TABLE II 
*  Civil War and Migration, Household Level Analysis, By gender
* --- --- --- --- --- --- --- --- ---

        *** Sample  
          cap restore
          preserve
          keep if restr_7==1
          variables

        * Adult vs Children
            bys id_hh year: egen extra_2=sum(leave) if sex==0
            sort id_hh year extra_2
            bys id_hh year: replace extra_2=extra_2[_n-1] if extra_2==.
            replace extra_2=0 if extra_2==.

            bys id_hh year: egen extra_2a=sum(leave) if sex==1
            sort id_hh year extra_2a
            bys id_hh year: replace extra_2a=extra_2a[_n-1] if extra_2a==.
            replace extra_2a=0 if extra_2a==.


        * bys id_hh year: gen hh=_n
            drop hh
            bys id_hh year: gen hh=_n
            keep if hh==1
            xtset id_hh year
            cap cap cap drop province_trend
            bys province year: gen province_trend=_n



        * Dept variables: Dummy 0/1 if any adult leaves
            gen d_female=(extra_2a>0)
            rename extra_2 extra_2b
            gen d_male=(extra_2b>0)


        * BASELINE RESULTS 
        * Set of variables for the analysis

                mat beta=J(2,4,0)
                mat se=J(2,4,0) 
                mat n=J(2,4,0)  
                mat mean_dep=J(2,4,0) 
                mat df=J(2,4,0) 

        * Column II: Household Approach - Village exposure 

            
            local s=1
            foreach i in  d_female d_male {
              local m=1
                foreach j in  $exposure  $intensity  index_agri index_asset {
                  qui xtreg `i'  `j'  i.year province_trend, cluster(reczd) fe
                  mat beta[`s',`m']=_b[`j']
                  mat se[`s',`m']=_se[`j']
                  mat n[`s',`m']=e(N)
                  mat df[`s',`m']=e(df_r)
                  qui su  `i'
                  mat mean_dep[`s',`m']=r(mean)
                  local m=`m'+1
                }
                local s=`s'+1
              }

        * Exporting Results


          * Gen P-value
              mat p_value=J(2,4,0)  
              forvalue i=1/4 {
                mat p_value[1,`i']=(2 * ttail(df[1,`i'], abs(beta[1,`i']/se[1,`i'])))
                mat p_value[2,`i']=(2 * ttail(df[2,`i'], abs(beta[2,`i']/se[2,`i'])))
              }

              
          * Gen Stars 

              forvalue i=1/4 {

                * P-value
                local p_value=p_value[1,`i']

                  if `p_value'>0.1 {
              local beta`i'  : display  "0" int(beta[1,`i']*1000)/1000 
              }

                    if `p_value'<=0.1 & `p_value'>0.05 {
              local beta`i'  : display "0" int(beta[1,`i']*1000)/1000  "*"
              }

              if `p_value'<=0.05  & `p_value'>0.01 {
              local beta`i'  : display "0" int(beta[1,`i']*1000)/1000  "**"
              }

              if `p_value'<=0.01 {
              local beta`i'  : display  "0" int(beta[1,`i']*1000)/1000  "***"
              }

            

              * P-value
                local p_value=p_value[2,`i']
                
                if `p_value'>0.1 {
              local beta1`i'  : display  "0" int(beta[2,`i']*1000)/1000 
              }

                    if `p_value'<=0.1 & `p_value'>0.05 {
              local beta1`i'  : display "0" int(beta[2,`i']*1000)/1000  "*"
              }

              if `p_value'<=0.05  & `p_value'>0.01 {
              local beta1`i'  : display "0" int(beta[2,`i']*1000)/1000  "**"
              }

              if `p_value'<=0.01 {
              local beta1`i'  : display  "0" int(beta[2,`i']*1000)/1000  "***"
              }
              
              }


          * Gen Std.Errors

              forvalue i=1/4 {
                local sd1=se[1,`i']
                local sd2=se[2,`i']
              local sd1_`i'  : display "[0"  int(`sd1'*1000)/1000  "]"
              local sd2_`i'  : display "[0"  int(`sd2'*1000)/1000  "]"
              }

             * Export Results
			 putexcel set "${results}", modify sheet("Appendix Table 2")
              putexcel C6=("`beta1'") C7=("`sd1_1'")  D9=("`beta2'") D10=("`sd1_2'") E12=("`beta3'") E13=("`sd1_3'") F14=("`beta4'") F15=("`sd1_4'") G6=("`beta11'") G7=("`sd2_1'") H9=("`beta12'") H10=("`sd2_2'") I12=("`beta13'") I13=("`sd2_3'") J14=("`beta14'") J15=("`sd2_4'")


                mat obs=J(1,8,0)
                mat dep_y=J(1,8,0)
                forvalue i=1/4 {
                  local j=`i'+4
                   mat obs[1,`i'] = n[1,`i']
                   mat obs[1,`j'] = n[2,`i']
                   mat dep_y[1,`i'] = mean_dep[1,`i']
                   mat dep_y[1,`j'] = mean_dep[2,`i']
                }
             
              * Mean and observation
              putexcel C16=matrix(obs) C17=matrix(dep_y) 


* --- --- --- --- --- --- --- --- --- 
* APPENDIX TABLE III 
*  Civil War and Migration, Household Level Analysis, By Poor-status
* --- --- --- --- --- --- --- --- ---

        *** Sample  
          cap restore
          preserve
          keep if restr_7==1
          variables
          drop if pov_stat98==.

        * Adult vs Children
            bys id_hh year: egen extra_2=sum(leave) if pov_stat98==0
            sort id_hh year extra_2
            bys id_hh year: replace extra_2=extra_2[_n-1] if extra_2==.
            replace extra_2=0 if extra_2==.

            bys id_hh year: egen extra_2a=sum(leave) if pov_stat98==1
            sort id_hh year extra_2a
            bys id_hh year: replace extra_2a=extra_2a[_n-1] if extra_2a==.
            replace extra_2a=0 if extra_2a==.


        * bys id_hh year: gen hh=_n
            drop hh
            bys id_hh year: gen hh=_n
            keep if hh==1
            xtset id_hh year
            cap cap cap drop province_trend
            bys province year: gen province_trend=_n



        * Dept variables: Dummy 0/1 if any adult leaves
            gen d_poor=(extra_2a>0)
            rename extra_2 extra_2b
            gen d_nonpoor=(extra_2b>0)


        * BASELINE RESULTS 
        * Set of variables for the analysis

                mat beta=J(2,4,0)
                mat se=J(2,4,0) 
                mat n=J(2,4,0)  
                mat mean_dep=J(2,4,0) 
                mat df=J(2,4,0) 

        * Column II: Household Approach - Village exposure 

            gen poor=1 if pov_stat98==0
            replace poor=2 if pov_stat98==1
            
            local s=1
            foreach i in  d_nonpoor d_poor {
              local m=1
                foreach j in  $exposure  $intensity  index_agri index_asset {
                  qui xtreg `i'  `j'  i.year province_trend if poor==`s', cluster(reczd) fe
                  mat beta[`s',`m']=_b[`j']
                  mat se[`s',`m']=_se[`j']
                  mat n[`s',`m']=e(N)
                  mat df[`s',`m']=e(df_r)
                  qui su  `i'
                  mat mean_dep[`s',`m']=r(mean)
                  local m=`m'+1
                }
                local s=`s'+1
              }

        * Exporting Results


          * Gen P-value
              mat p_value=J(2,4,0)  
              forvalue i=1/4 {
                mat p_value[1,`i']=(2 * ttail(df[1,`i'], abs(beta[1,`i']/se[1,`i'])))
                mat p_value[2,`i']=(2 * ttail(df[2,`i'], abs(beta[2,`i']/se[2,`i'])))
              }

              
          * Gen Stars 

              forvalue i=1/4 {

                * P-value
                local p_value=p_value[1,`i']

                  if `p_value'>0.1 {
              local beta`i'  : display  "0" int(beta[1,`i']*1000)/1000 
              }

                    if `p_value'<=0.1 & `p_value'>0.05 {
              local beta`i'  : display "0" int(beta[1,`i']*1000)/1000  "*"
              }

              if `p_value'<=0.05  & `p_value'>0.01 {
              local beta`i'  : display "0" int(beta[1,`i']*1000)/1000  "**"
              }

              if `p_value'<=0.01 {
              local beta`i'  : display  "0" int(beta[1,`i']*1000)/1000  "***"
              }

            

              * P-value
                local p_value=p_value[2,`i']
                
                if `p_value'>0.1 {
              local beta1`i'  : display  "0" int(beta[2,`i']*1000)/1000 
              }

                    if `p_value'<=0.1 & `p_value'>0.05 {
              local beta1`i'  : display "0" int(beta[2,`i']*1000)/1000  "*"
              }

              if `p_value'<=0.05  & `p_value'>0.01 {
              local beta1`i'  : display "0" int(beta[2,`i']*1000)/1000  "**"
              }

              if `p_value'<=0.01 {
              local beta1`i'  : display  "0" int(beta[2,`i']*1000)/1000  "***"
              }
              
              }


          * Gen Std.Errors

              forvalue i=1/4 {
                local sd1=se[1,`i']
                local sd2=se[2,`i']
              local sd1_`i'  : display "[0"  int(`sd1'*1000)/1000  "]"
              local sd2_`i'  : display "[0"  int(`sd2'*1000)/1000  "]"
              }

               * Export Results
			  putexcel set "${results}", modify sheet("Appendix Table 3")
              putexcel C6=("`beta1'") C7=("`sd1_1'")  D9=("`beta2'") D10=("`sd1_2'") E12=("`beta3'") E13=("`sd1_3'") F14=("`beta4'") F15=("`sd1_4'") G6=("`beta11'") G7=("`sd2_1'") H9=("`beta12'") H10=("`sd2_2'") I12=("`beta13'") I13=("`sd2_3'") J14=("`beta14'") J15=("`sd2_4'")


                mat obs=J(1,8,0)
                mat dep_y=J(1,8,0)
                forvalue i=1/4 {
                  local j=`i'+4
                   mat obs[1,`i'] = n[1,`i']
                   mat obs[1,`j'] = n[2,`i']
                   mat dep_y[1,`i'] = mean_dep[1,`i']
                   mat dep_y[1,`j'] = mean_dep[2,`i']
                }
             
              * Mean and observation
              putexcel C16=matrix(obs) C17=matrix(dep_y)  

