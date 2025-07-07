* --- --- --- --- --- --- --- --- --- 
* Defining Working Paths  
* --- --- --- --- --- --- --- --- --- 
	
	clear all
	global path_work "C:\Users\Stefany Lopez\OneDrive - Universidad EAFIT\VP\Burundi\nuevo"
 
* --- --- --- --- --- --- --- --- --- 
* We include the data preliminaries 
* --- --- --- --- --- --- --- --- --- 
  
	run "$path_work/do-files/0_DataPreliminaries_Akresh-etal_2025.do"
  
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
	
	    *** Analysis at Household level
		cap bys id_hh year: gen hh=_n		 
		keep if hh==1
		xtset id_hh year
		cap drop province_trend
		bys province year: gen province_trend=_n

		cap drop pca_agri pca_asset pca_all
		
		* Agricultural losses: land and/or crops
		pca sk_vl_rob_land sk_vl_rob_product, components(1)
		predict pca_agri, score 


		* Asset-related losses: money, goods, house
		pca sk_vl_rob_money sk_vl_rob_goods sk_vl_rob_destruction, components(1)
		predict pca_asset, score 

		* Household losses: all five dimensions
		pca sk_vl_rob_land sk_vl_rob_product sk_vl_rob_money sk_vl_rob_goods sk_vl_rob_destruction, components(1)
		predict pca_all, score 
		
		sum pca_all if !missing(pca_all)
		gen pca_all_abovemean = (pca_all > r(mean)) if !missing(pca_all) 
		
		* Weather shocks: Droughts and extreme rain 
		pca sk_nt_drought sk_nt_rain, components(1)
		predict pca_weather, score 		
		
		* Natural shocks: Low, good harvest, erosion
		pca  sk_nt_crop_bad sk_nt_crop_good sk_nt_erosion sk_nt_drought sk_nt_rain, components(1)
		predict pca_natural, score  
	
		pca  sk_nt_crop_bad sk_nt_crop_good sk_nt_erosion sk_nt_drought sk_nt_rain, components(1)
		predict pca_natural_all, score  
		* Save
		keep id_hh year pca_agri pca_asset pca_all pca_all_abovemean pca_natural pca_weather pca_natural_all
		save "$path_work/data/pca.dta", replace