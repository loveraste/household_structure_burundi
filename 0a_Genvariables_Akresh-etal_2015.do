************ Creating Variables  ************
			capt prog drop variables
			program variables, eclass
			
				cap gen deathwounded_100=deathwounded/100 
				* PANEL B - (individual level) -  Generating the dependent variable by person
				cap drop n_ind
				qui bys id_person: gen n_ind=_n
				bys id_person: egen sum_leave=sum(leave)
				qui bys id_person: gen d_leave_ind=(sum_leave!=0)
		
				* PANEL C - (Household-year level) - Generating the dependent variable by household-year
				cap bys id_hh year: gen hh=_n
				cap bys id_hh year: egen leave_hh=sum(leave)
				sort id_hh year leave_hh
	
				cap bys id_hh year: replace leave_hh=leave_hh[_n-1] if leave_hh==.
				cap bys id_hh year: replace leave_hh=0 if leave_hh==.
		
				cap bys id_hh year: gen d_leave_hh=(leave_hh!=0)
	
				sort id_hh year d_leave_hh
				cap bys id_hh year:replace d_leave_hh=d_leave_hh[_n-1] if d_leave_hh==.
				cap bys id_hh year:replace d_leave_hh=0 if d_leave_hh==.

				* For continuous variable - Generating independent variables by HH
				foreach i in  deathwounded_100 leave_hh cff_income livestock  {
				cap drop hh_`i'
				bys id_hh year: egen hh_`i'=mean(`i') 
				}

				* For binary variables - Generating independent variables by HH 
				foreach i in sk_vl_rob_money sk_vl_rob_product sk_vl_rob_goods sk_vl_rob_destruction sk_vl_rob_land {
				gsort id_hh year - `i'
				bys id_hh year: replace `i'=`i'[_n-1] if `i'!=`i'[_n-1] & `i'[_n-1]!=.
				}

				* Index for household level
				gen index_agri=sk_vl_rob_land+sk_vl_rob_product
				gen index_asset=sk_vl_rob_money+sk_vl_rob_goods+sk_vl_rob_destruction

				foreach i in sk_vl_rob_land sk_vl_rob_product sk_vl_rob_money  sk_vl_rob_goods sk_vl_rob_destruction   index_agri index_asset{
				sort id_hh year
				bys id_hh: gen lag_`i'=`i'[_n-1]
				}

			* PANEL D - (Household level) - Generating the dependent variable by household (without year)
				cap bys id_hh: gen n_hh=_n
				cap drop leave_hh_t	
				cap bys id_hh:egen leave_hh_t=sum(leave)
				sort id_hh leave_hh_t
				bys id_hh: replace leave_hh_t=leave_hh_t[_n-1] if  leave_hh_t==.
				replace leave_hh_t=0 if leave_hh_t==.
				cap drop d_leave_hh_t	
				bys id_hh: gen d_leave_hh_t=(leave_hh_t>0)

				* For binary variables
				foreach i in d_violence sk_vl_rob_money sk_vl_rob_product sk_vl_rob_goods sk_vl_rob_destruction sk_vl_rob_land {
				cap drop hh_`i'
				cap drop s_`i'
				bys id_hh:egen s_`i'=sum(`i')
				bys id_hh:gen hh_`i'=1 if s_`i'!=0 
				bys id_hh:replace  hh_`i'=0 if s_`i'==0
				drop s_`i'
				}

			* PANEL E - (Village-year level)
				bys reczd year: gen n_vill_y=_n
				bys reczd year: egen v_deathwounded=mean(deathwounded_100)
				bys reczd year: egen v_s_violence=sum(d_violence)
				bys reczd year: gen v_d_violence=1 if v_s_violence!=0
				bys reczd year: replace v_d_violence=0 if v_s_violence==0
	
			* PANEL F - (Village level)
				bys reczd: gen n_vill=_n
				bys reczd: egen v1_s_violence=sum(d_violence)
				bys reczd: gen v1_d_violence=1 if v1_s_violence!=0
				bys reczd: replace v1_d_violence=0 if v1_s_violence==0


				end
