# ============================================================
# Civil War and Household Structure - Burundi
# Akresh, Muñoz-Mora & Verwimp (2025)
# ============================================================
# Variable Labels (translated from labels.do)
# ============================================================

# Variable label lookup table
var_labels <- c(
  # Individual-level
  d_leave_ind           = "Fraction of individuals that ever left the household",
  d_violence            = "Violence in a given year (yes=1)",
  deathwounded_100      = "Number of casualties in a given year",
  leave                 = "Fraction of years when individual left the household",

  # Household-year level
  hh_d_violence         = "Violence in a given year (yes=1)",
  hh_deathwounded       = "Number of casualties in a given year",
  d_leave_hh            = "At least 1 person left the household in a given year (yes=1)",
  leave_hh              = "Average number of people leaving the household in a given year",
  hh_cff_income         = "Average annual coffee income",
  hh_livestock          = "Average annual livestock holdings (in tlu)",

  # Violent shock variables (household-year)
  sk_vl_rob_land        = "Loss of land (yes=1) for a household in a given year",
  sk_vl_rob_product     = "Theft of crops (yes=1) for a household in a given year",
  sk_vl_rob_goods       = "Theft or destruction of goods (yes=1) for a household in a given year",
  sk_vl_rob_destruction = "Destruction of house (yes=1) for a household in a given year",
  sk_vl_rob_money       = "Theft of money (yes=1) for a household in a given year",

  # War-related shocks
  sk_jail               = "Time in prison (yes=1) for a household in 1998-2007",
  sk_movi               = "Joining armed group (yes=1) for a household in 1998-2007",
  sk_att                = "Victim of ambush (yes=1) for a household in 1998-2007",
  sk_kidnap             = "Captured or kidnapped (yes=1) for a household in 1998-2007",
  sk_workforced         = "Forced unpaid labor (yes=1) for a household in 1998-2007",
  sk_torture            = "Beaten or tortured (yes=1) for a household in 1998-2007",
  sk_contribution       = "Forced contributions paid (yes=1) for a household in 1998-2007",

  # Natural shocks
  sk_nt_rain            = "Excessive rainfall (yes=1) for a household in 1998-2007",
  sk_nt_drought         = "Drought or lack of rain (yes=1) for a household in 1998-2007",
  sk_nt_disease         = "Crop disease (yes=1) for a household in 1998-2007",
  sk_nt_crop_bad        = "Bad harvest (yes=1) for a household in 1998-2007",
  sk_nt_destru_rain     = "House destruction by rain (yes=1) for a household in 1998-2007",
  sk_nt_erosion         = "Severe landslide or erosion (yes=1) for a household in 1998-2007",

  # Economic shocks
  sk_ec_input_access    = "No access to inputs (yes=1) for a household in 1998-2007",
  sk_ec_input_price     = "Increase in input prices (yes=1) for a household in 1998-2007",
  sk_ec_nonmarket       = "Lack of market access (yes=1) for a household in 1998-2007",
  sk_ec_output_price    = "Decrease in crop prices (yes=1) for a household in 1998-2007",
  sk_ec_sell_land       = "Sale of land (yes=1) for a household in 1998-2007",
  sk_ec_sell_other      = "Sale of house (yes=1) for a household in 1998-2007",
  sk_ec_rec_help        = "Humanitarian aid received (yes=1) for a household in 1998-2007",

  # Household-level aggregates (ever experienced)
  hh_sk_vl_rob_money       = "Household ever experienced theft of money",
  hh_sk_vl_rob_product     = "Household ever experienced theft of crops",
  hh_sk_vl_rob_goods       = "Household ever experienced theft or destruction of good",
  hh_sk_vl_rob_destruction = "Household ever experienced destruction of house",
  hh_sk_vl_rob_land        = "Household ever experienced loss of land",

  # Village-level
  v_d_violence          = "Fraction of years when village experienced violence",
  v_deathwounded        = "Number of casualties in a given year",
  v1_d_violence         = "Fraction of villages that ever experienced violence at least one year during 1998-2007",
  v_s_violence          = "Number of years with presence of violence during 1998-2007",

  # Household level (aggregated over all years)
  leave_hh_t            = "Number of members of household that migrated outside household",
  d_leave_hh_t          = "Fraction of individuals that ever left the household",

  # Migration outcome variables
  any_leave             = "At least 1 household member left the household in a given year (yes=1)",
  total_leave           = "Number of household members who left household 1998-2007",
  share_leave           = "Share of household members who left household 1998-2007",
  any_leave_adult       = "At least 1 adult left the household in a given year (yes=1)",
  total_leave_adult     = "Number of adults who left household 1998-2007",
  share_leave_adult     = "Share of adults who left household 1998-2007",
  any_leave_child       = "At least 1 child left the household in a given year (yes=1)",
  total_leave_child     = "Number of children who left household 1998-2007",
  share_leave_child     = "Share of children who left household 1998-2007",
  any_leave_woman       = "At least 1 female left the household in a given year (yes=1)",
  total_leave_woman     = "Number of females who left household 1998-2007",
  share_leave_woman     = "Share of females who left household 1998-2007",
  any_leave_man         = "At least 1 male left the household in a given year (yes=1)",
  total_leave_man       = "Number of males who left household 1998-2007",
  share_leave_man       = "Share of males who left household 1998-2007",

  # Conflict history (household-level)
  any_violence          = "Dummy presence of violence during 1998-2007 (yes=1)",
  years_violence        = "Number of years with presence of violence during 1998-2007",
  avg_deathwounded_100  = "Average dead and wounded per 100 people per year, 1998-2007",

  # Indexes
  index_agri            = "Index of Agricultural Related Losses (land and/or crops)",
  index_asset           = "Index of Asset Related Losses (money, goods, and/or house)",

  # PCA variables
  pca_all               = "Conflict-caused losses of land/crops and assets (PCA index)",
  pca_agri              = "Conflict-caused loss of land/crops (PCA index)",
  pca_asset             = "Conflict-caused loss of assets (PCA index)",
  pca_economic          = "Economic shocks (input prices, market access) (PCA index)",
  pca_coping            = "Coping strategies (asset/land sales, external help) (PCA index)",
  pca_weather           = "Extreme rain/drought shocks (PCA index)",
  pca_natural           = "Bad harvest/soil erosion shocks (PCA index)",
  pca_natural_all       = "Extreme rain/drought/bad harvest/soil erosion shocks (PCA index)",

  # Poverty status
  Poverty_status_98     = "Poverty status of the household in 1998 (yes=1)",
  Poverty_status_07     = "Poverty status of the household in 2007 (yes=1)"
)

#' Get variable label
#'
#' @param var_name Character string, variable name
#' @return Character string with label, or var_name if not found
get_label <- function(var_name) {
  if (var_name %in% names(var_labels)) {
    return(var_labels[[var_name]])
  }
  return(var_name)
}

#' Apply labels to a data frame as attributes
#'
#' @param df Data frame
#' @return Data frame with label attributes set
apply_labels <- function(df) {
  for (v in names(df)) {
    if (v %in% names(var_labels)) {
      attr(df[[v]], "label") <- var_labels[[v]]
    }
  }
  df
}
