cap label var d_leave_ind "Fraction of individuals that ever left the household"
cap label var d_violence "Violence in a given year (yes=1)"
cap label var deathwounded_100 "Number of causalties in a given year"
cap label var leave "Fraction of years when individual left the household"
cap label var hh_d_violence "Violence in a given year (yes=1)"
cap label var hh_deathwounded "Number of causalties in a given year"
cap label var d_leave_hh "At least 1 person left the household in a given year (yes=1)"
cap label var leave_hh "Average number of people leaving the household in a given year"
cap label var v_s_violence "Number of years with presence of violence during 1998-2007"

cap label var hh_cff_income "Average annual coffee income"
cap label var  hh_livestock "Average annual livestock holdings (in tlu)*"
cap label var sk_vl_rob_money "Theft of money (yes=1) for a household in a given year"
cap label var  sk_vl_rob_product "Theft of crops (yes=1) for a household in a given year"
cap label var sk_vl_rob_goods  "Theft or destruction of goods (yes=1) for a household in a given year"
cap label var sk_vl_rob_destruction "Destruction of house (yes=1) for a household in a given year"
cap label var  sk_vl_rob_land "Loss of land (yes=1) for a household in a given year"

cap label var hh_sk_vl_rob_money "Household ever experienced theft of money"
cap label var  hh_sk_vl_rob_product "Household ever experienced theft of crops"
cap label var hh_sk_vl_rob_goods  "Household ever experienced theft or destruction of good"
cap label var hh_sk_vl_rob_destruction "Household ever experienced destruction of house"
cap label var  hh_sk_vl_rob_land "Household ever experienced loss of land"

cap label var v_d_violence "Number of causalties in a given year"
cap label var v_deathwounded "Fraction of years when village experienced violence"
cap label var v1_d_violence "Fraction of villages that ever experienced violence at least one year during 1998-2007"

cap label var deathwounded_100 "Number of causalties in a given year"

cap labe var leave_hh_t "Number of member of household that migrated outside household "
cap label var d_leave_hh_t "Fraction of individuals that ever left the household"

cap labe var a_coffee_produc_97 "Area (ha) of coffee production in a productive age ($<= 8$ years old) in 1997"
cap labe var density_97 "Crop Density (trees x ha) (1997)"
cap labe var lotes_97 "Number of coffee fields (1997)"


cap label var any_leave "At least 1 person left the household in a given year (yes=1)"
cap label var total_leave "Number of members who left household 1998-2007"
cap label var share_leave "Share of household members who left household 1998-2007"
cap label var any_leave_adult "At least 1 adult left the household in a given year (yes=1)"
cap label var total_leave_adult "Number of adults who left household 1998-2007"
cap label var share_leave_adult "Share of adults  who left household 1998-2007"


local keys "leave leave_adult leave_child leave_woman leave_man"
local who  `" "household member" "adult" "child"  "female" "male" "'
local Who  `" "household members" "adults" "children" "females" "males" "'

forvalues i = 1/`=wordcount("`keys'")' {
    local k   : word `i' of `keys'
    local w   : word `i' of `who'
    local W   : word `i' of `Who'

    cap label variable any_`k'   "At least 1 `w' left the household in a given year (yes=1)"
    cap label variable total_`k' "Number of `W' who left household 1998–2007"
    cap label variable share_`k' "Share of `W' who left household 1998–2007"
}

cap label var any_violence         "Dummy presence of violence during 1998–2007 (yes=1)"
cap label var years_violence       "Number of years with presence of violence during 1998–2007"
cap label var avg_deathwounded_100 "Average dead and wounded per 100 people per year, 1998–2007"

local codes ///
    "sk_vl_rob_land sk_vl_rob_product sk_vl_rob_money sk_vl_rob_goods sk_vl_rob_destruction sk_jail sk_movi sk_att sk_kidnap sk_workforced sk_torture sk_contribution sk_nt_rain sk_nt_drought sk_nt_disease sk_nt_crop_good sk_nt_crop_bad sk_nt_destru_rain sk_nt_erosion sk_ec_input_access sk_ec_input_price sk_ec_nonmarket sk_ec_output_price sk_ec_sell_land sk_ec_sell_other sk_ec_rec_help"

local texts ///
    `" "Loss of land" "Theft of crops" "Theft of money" "Theft or destruction of goods" "Destruction of house"  "Time in prison" "Joining armed group" "Victim of ambush" "Captured or kidnapped" "Forced unpaid labor" "Beaten or tortured" "Forced contributions paid" "Excessive rainfall" "Drought or lack of rain" "Crop disease" "Good harvest" "Bad harvest" "House destruction by rain" "Severe landslide or erosion" "No access to inputs" "Increase in input prices" "Lack of market access" "Decrease in crop prices" "Sale of land" "Sale of house" "Humanitarian aid received" "'

forvalues i = 1/`=wordcount("`codes'")' {
    local c : word `i' of `codes'
    local t : word `i' of `texts'
	
    cap label var any_`c' "`t' (yes=1) for a household in 1998–2007"

    local t_lower = lower(substr("`t'",1,1)) + substr("`t'",2,.)
    cap label var years_`c' "Number of years the household experienced `t_lower' (1998–2007)"
}


local pcas  "pca_all_mean pca_agri_mean pca_asset_mean pca_economic_mean pca_coping_mean pca_weather_mean pca_natural_mean pca_natural_all_mean"

local texts `"  "Conflict-caused losses of land/crops and assets"  "Conflict-caused loss of land/crops"  "Conflict-caused loss of assets"  "Economic shocks (input prices, market access)"  "Coping strategies (asset/land sales, external help)"  "Extreme rain/drought shocks"  "Bad harvest/soil erosion shocks" "Extreme rain/drought/bad harvest/soil erosion shocks" "'

forvalues i = 1/`=wordcount("`pcas'")' {
    local p : word `i' of `pcas'
    local t : word `i' of `texts'

    cap label variable `p' "`t'"
}

cap label var Poverty_status_98 "Poverty status of the household in 1998 (yes=1)"
cap label var Poverty_status_07 "Poverty status of the household in 2007 (yes=1)"
