/*******************************************************************************
 * PRINCIPAL COMPONENT ANALYSIS (PCA) GENERATION
 * Project: Civil War and Household Composition
 * Authors: Akresh, Verwimp and Muñoz (2025)
 * File: 00b_Gen_PCA.do
 * 
 * Purpose: Generate principal component indices for different types of shocks
 *          and losses experienced by households during civil conflict
 * 
 * Input:   panel_individual.dta (loaded via 00_DataPreliminaries_Akresh-etal_2025.do)
 * Output:  pca.dta (contains PCA scores for different shock categories)
 * 
 * Dependencies: 00_DataPreliminaries_Akresh-etal_2025.do
 * 
 * Structure:
 *   1. Data preparation and sample selection
 *   2. PCA construction for different shock categories:
 *      - Agricultural losses (land and crops)
 *      - Asset-related losses (money, goods, house destruction)
 *      - Combined household losses (all five dimensions)
 *      - Weather shocks (droughts and extreme rain)
 *      - Natural shocks (comprehensive agricultural and weather)
 *   3. Data saving
 * 
 * Last modified: July 2025
 *******************************************************************************/

// Clear workspace and set environment
	clear all
	set more off

// Load data with preliminaries
  
	run "do-files/00_DataPreliminaries_Akresh-etal_2025.do"

/*------------------------------------------------------------------------------
 * 1. SAMPLE SELECTION AND DATA PREPARATION
 *----------------------------------------------------------------------------*/

	// Keep only parental households (numsplit==0)
	// This restricts analysis to original household heads, excluding split households
	keep if numsplit==0
	
	// Clean age variable
	drop if age==.
	drop age
	gen age=year-born_year_07
	// *drop if born_year_07>1998  // Optional: exclude very young household heads
	
	// Keep only registered household members from 1998 census
	drop if Code98==.	

/*------------------------------------------------------------------------------
 * 2. HOUSEHOLD-LEVEL ANALYSIS SETUP
 *----------------------------------------------------------------------------*/

	// Create household-level dataset (one observation per household-year)
	cap bys id_hh year: gen hh=_n		 
	keep if hh==1
	xtset id_hh year
	
	// Generate province-year trend variable
	cap drop province_trend
	bys province year: gen province_trend=_n

/*------------------------------------------------------------------------------
 * 3. PRINCIPAL COMPONENT ANALYSIS (PCA) CONSTRUCTION
 *----------------------------------------------------------------------------*/

	// Drop existing PCA variables if they exist
	cap drop pca_*
		
	/* 3A. Agricultural Losses PCA
	 * Variables: sk_vl_rob_land (land robbery), sk_vl_rob_product (crop/product theft)
	 * Captures: Direct agricultural asset losses during conflict */
	pca sk_vl_rob_land sk_vl_rob_product, components(1)
	predict pca_agri, score 

	/* 3B. Asset-Related Losses PCA  
	 * Variables: sk_vl_rob_money (money theft), sk_vl_rob_goods (goods theft), 
	 *           sk_vl_rob_destruction (house destruction)
	 * Captures: Non-agricultural household asset losses */
	pca sk_vl_rob_money sk_vl_rob_goods sk_vl_rob_destruction, components(1)
	predict pca_asset, score 

	/* 3C. Comprehensive Household Losses PCA
	 * Variables: All five violence-related loss dimensions
	 * Captures: Overall household victimization from conflict violence */
	pca sk_vl_rob_land sk_vl_rob_product sk_vl_rob_money sk_vl_rob_goods sk_vl_rob_destruction, components(1)
	predict pca_all, score 
	
	// Generate binary indicator for above-mean losses
	egen pca_mean = mean(pca_all) if !missing(pca_all)
	gen pca_all_abovemean = (pca_all >= pca_mean) 
	
	/* 3D. Weather Shocks PCA
	 * Variables: sk_nt_drought (drought), sk_nt_rain (extreme rainfall)  
	 * Captures: Climate-related agricultural disruptions */
	pca sk_nt_drought sk_nt_rain, components(1)
	predict pca_weather, score 		
	
	/* 3E. Natural Shocks PCA (Comprehensive)
	 * Variables: sk_nt_crop_bad (bad harvest), sk_nt_crop_good (good harvest),
	 *           sk_nt_erosion (soil erosion)
	 * Captures:Environmental shocks affecting agriculture */
	pca sk_nt_crop_bad sk_nt_erosion, components(1)
	predict pca_natural, score  
	
	/* 3F. All weather and natural Shocks PCA
	 * Variables: All natural and weather shocks
	 *Capture: General impacts on households due to climate or nature*/
	pca sk_nt_crop_bad sk_nt_erosion sk_nt_drought sk_nt_rain, components(1)
	predict pca_natural_all, score  
	
	/* 3G. Economic Shocks PCA
	* Variables: sk_ec_input_access (Acces to inputs), sk_ec_input_price (Input prices), sk_ec_nonmarket (no market access)
	* sk_ec_output_price (output prices), sk_ec_sell_land (land sale), sk_ec_sell_other (sale other assets), sk_ec_rec_help (reciving help)
	* Capture: Composite index of exposure to market disruptions (input/output access & prices) */
	pca sk_ec_input_access sk_ec_input_price sk_ec_nonmarket sk_ec_output_price 
	predict pca_economic, score
	
	/* 3H. Coping Shocks PCA
	 Capture: Composite index of liquidity-coping responses */
	pca sk_ec_sell_land sk_ec_sell_other sk_ec_rec_help
	predict pca_coping, score
	
/*------------------------------------------------------------------------------
 * 3G. TRANSFORM PCA SCORES TO POSITIVE VALUES
 *----------------------------------------------------------------------------*/

	// Transform PCA scores to positive scale (min-max normalization to 0-100)
	// This makes interpretation easier and ensures all values are positive
	
	foreach var in pca_agri pca_asset pca_all pca_natural pca_weather pca_natural_all pca_economic pca_coping {
		quietly summarize `var'
		gen `var'_pos = ((`var' - r(min)) / (r(max) - r(min))) * 100
		label variable `var'_pos "`var' transformed to 0-100 scale"
	}
	
	// Alternative: Standardize and shift to positive (mean=50, sd=10)
	foreach var in pca_agri pca_asset pca_all pca_natural pca_weather pca_natural_all pca_economic pca_coping {
		quietly summarize `var'
		gen `var'_std = ((`var' - r(mean)) / r(sd)) * 10 + 50
		label variable `var'_std "`var' standardized (mean=50, sd=10)"
	}
	
	// Create binary indicators based on positive transformations
	foreach var in pca_agri pca_asset pca_all pca_natural pca_weather pca_natural_all pca_economic pca_coping {
		quietly summarize `var'_pos
		gen `var'_high = (`var'_pos > r(mean)) if !missing(`var'_pos)
		label variable `var'_high "High `var' (above mean of positive scale)"
	}

	// Display transformation summary
	display ""
	display "=== PCA TRANSFORMATION SUMMARY ==="
	display "Created positive transformations:"
	display "  - *_pos: Min-max normalized to 0-100 scale"
	display "  - *_std: Standardized with mean=50, sd=10" 
	display "  - *_high: Binary indicators for above-mean values"
	display "  - *_log: Log of positive transformation (recommended)"
	display "  - *_logshift: Shifted logarithm of original values"
	display "  - *_logmod: Log modulus transformation (preserves sign)"
	display ""

// Logarithmic transformations for PCA variables
	// Note: Adding constant to handle negative values and zeros
	foreach var in pca_agri pca_asset pca_all pca_natural pca_weather pca_natural_all pca_economic pca_coping {
		quietly summarize `var'
		// Method 1: Log of positive transformation (recommended)
		gen `var'_log = ln(`var'_pos + 1)
		label variable `var'_log "Log(`var'_pos + 1)"
		
		// Method 2: Shifted log (for original values)
		local shift = abs(r(min)) + 1
		gen `var'_logshift = ln(`var' + `shift')
		label variable `var'_logshift "Log(`var' + `shift')"
		
		// Method 3: Log modulus transformation (preserves sign)
		gen `var'_logmod = sign(`var') * ln(abs(`var') + 1)
		label variable `var'_logmod "Sign(`var') * ln(abs(`var') + 1)"
	}

/*------------------------------------------------------------------------------
 * 4. DATA EXPORT
 *----------------------------------------------------------------------------*/

	// Keep essential variables including all transformations
	keep id_hh year ///
		pca_agri pca_asset pca_all pca_all_abovemean pca_natural pca_weather pca_natural_all pca_economic pca_coping ///
		pca_agri_pos pca_asset_pos pca_all_pos pca_natural_pos pca_weather_pos pca_natural_all_pos pca_economic_pos pca_coping_pos ///
		pca_agri_std pca_asset_std pca_all_std pca_natural_std pca_weather_std pca_natural_all_std ///
		pca_agri_high pca_asset_high pca_all_high pca_natural_high pca_weather_high pca_natural_all_high ///
		pca_agri_log pca_asset_log pca_all_log pca_natural_log pca_weather_log pca_natural_all_log ///
		pca_agri_logshift pca_asset_logshift pca_all_logshift pca_natural_logshift pca_weather_logshift pca_natural_all_logshift ///
		pca_agri_logmod pca_asset_logmod pca_all_logmod pca_natural_logmod pca_weather_logmod pca_natural_all_logmod

	// Ensure all variables are labeled appropriately
	foreach i in pca_agri pca_asset pca_all pca_natural pca_weather pca_natural_all pca_economic pca_coping {
		replace `i' = `i'_pos/100
		bys id_hh: egen `i'_hh = mean(`i') if !missing(`i')
	}

	// Gen a Household-level
	keep id_hh year pca_agri pca_asset pca_all pca_all_abovemean pca_natural pca_weather pca_natural_all pca_economic pca_coping *_hh
	
	// labels 
	
	cap label variable pca_agri          "Conflict-caused loss of land/crops"
	cap label variable pca_asset         "Conflict-caused loss of assets"
	cap label variable pca_all           "Conflict-caused losses of land/crops and assets"
	cap label variable pca_all_abovemean "Conflict-caused losses of land/crops and assets - above the mean (yes=1)"
	cap label variable pca_weather       "Extreme rain/drought shocks"
	cap label variable pca_natural       "Bad harvest/soil erosion shocks"
	cap label variable pca_natural_all   "Extreme rain/drought/bad harvest/soil erosion shocks"
	cap label variable pca_economic      "Economic shocks (input prices, market access)"
	cap label variable pca_coping        "Coping strategies (asset/land sales, external help)"

	
	cap label variable pca_agri_hh        "Conflict-caused loss of land/crops"
	cap label variable pca_asset_hh       "Conflict-caused loss of assets"
	cap label variable pca_all_hh         "Conflict-caused losses of land/crops and assets"
	cap label variable pca_natural_hh     "Bad harvest/soil erosion shocks"
	cap label variable pca_weather_hh     "Extreme rain/drought shocks"
	cap label variable pca_natural_all_hh "Extreme rain/drought/bad harvest/soil erosion shocks"
	cap label variable pca_economic_hh      "Economic shocks (input prices, market access)"
	cap label variable pca_coping_hh        "Coping strategies (asset/land sales, external help)"


	// Save PCA dataset for use in subsequent analyses
	save "$path_work/data/job/pca.dta", replace
	
	// Display final dataset information
	display ""
	display "=== FINAL DATASET SUMMARY ==="
	display "PCA dataset created successfully with " _N " observations"
	display ""
	display "Original PCA variables:"
	display "  pca_agri, pca_asset, pca_all, pca_all_abovemean, pca_natural, pca_weather, pca_natural_all"
	display ""
	display "Positive transformations added:"
	display "  *_pos (0-100 scale), *_std (mean=50, sd=10), *_high (binary indicators)"
	display "Logarithmic transformations added:"
	display "  *_log (log of positive scale), *_logshift (shifted log), *_logmod (signed log)"
	display ""
	display "Dataset saved to: $path_work/data/job/pca.dta"
	
	
	