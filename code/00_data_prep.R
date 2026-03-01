# ============================================================
# Civil War and Household Structure - Burundi
# Akresh, Muñoz-Mora & Verwimp (2025)
# ============================================================
# 00: Data Preparation
# Equivalent to:
#   - 00_DataPreliminaries_Akresh-etal_2025.do
#   - 00a_Genvariables_Akresh-etal_2025.do
#   - labels.do
# ============================================================

library(haven)
library(tidyverse)

source("code/utils/labels.R")
source("code/utils/helpers.R")

# ============================================================
# 1. LOAD MAIN DATASET
# ============================================================

cat("Loading main panel dataset...\n")
df_raw <- read_dta("data/final/panel_individual.dta")

# ============================================================
# 2. GENERATE IDs & PANEL SETUP
# ============================================================
# Stata: egen id_person = concat(reczd numen numsplit pid07)
#        egen id_hh     = concat(reczd numen)

df <- df_raw %>%
  mutate(
    id_person = as.numeric(paste0(reczd, numen, numsplit, pid07)),
    id_hh     = as.numeric(paste0(reczd, numen))
  )

# ============================================================
# 3. GENERATE KEY VARIABLES
# ============================================================

df <- df %>%
  mutate(
    # Log coffee income
    log_coffe           = log(cff_income + 1),
    # Violence intensity (per 100 population)
    deathwounded_100    = deathwounded / 100,
    lag_deathwounded_100 = lag_deathwounded / 100,
    # Age dummies
    adult_15 = as.integer(age >= 15),
    adult_18 = as.integer(age >= 18),
    # Violence exposure (binary)
    d_violence = as.integer(deathwounded > 0)
  )

# ============================================================
# 4. FILL MISSING SHOCK VARIABLES WITH 0
# ============================================================
# Stata: foreach i in sk_*: replace i=0 if i==.
# Assumption: missing = no shock occurred

df <- df %>%
  mutate(across(all_of(shock_vars), ~replace_na(., 0)))

# ============================================================
# 5. SAMPLE RESTRICTIONS
# ============================================================
# type_people: 1=permanent, 2=temporary, 3=no migration
# mig_why: 3=marriage
# restr_7 = all without marriage (BASELINE)

df <- df %>%
  mutate(
    restr_1 = 1L,
    restr_2 = as.integer(type_people == 1 | type_people == 3),  # Permanent or non-mig
    restr_3 = as.integer(type_people == 2 | type_people == 3),  # Temporary or non-mig
    restr_4 = as.integer(type_people == 1 | type_people == 2),  # Permanent or temporary
    restr_5 = as.integer(type_people == 1 & mig_why == 3 | type_people == 3),  # Perm/marriage
    restr_6 = as.integer(type_people == 1 & mig_why == 3),       # Marriage only
    restr_7 = as.integer(mig_why != 3 | is.na(mig_why))          # All without marriage
  )

# ============================================================
# 6. MERGE INSTRUMENTS
# ============================================================

cat("Merging instruments (altitude, rainfall, temperature)...\n")
inst <- read_dta("data/final/inst.dta") %>%
  select(reczd, altitude_av__m_, rainfall_av__mm_, temp_av)

df <- df %>%
  left_join(inst, by = "reczd")

# ============================================================
# 7. GENERATE DEPENDENT AND DERIVED VARIABLES
# ============================================================
# Panel B: Individual-level migration indicators

df <- df %>%
  group_by(id_person) %>%
  mutate(
    n_ind      = row_number(),
    sum_leave  = sum(leave, na.rm = TRUE),
    d_leave_ind = as.integer(sum_leave > 0)
  ) %>%
  ungroup()

# Panel C: Household-year level
df <- df %>%
  group_by(id_hh, year) %>%
  mutate(
    hh          = row_number(),
    leave_hh    = sum(leave, na.rm = TRUE),
    d_leave_hh  = as.integer(leave_hh > 0)
  ) %>%
  ungroup()

# Household-year means of continuous variables
df <- df %>%
  group_by(id_hh, year) %>%
  mutate(
    hh_deathwounded_100 = mean(deathwounded_100, na.rm = TRUE),
    hh_leave_hh         = mean(leave_hh, na.rm = TRUE),
    hh_cff_income       = mean(cff_income, na.rm = TRUE),
    hh_livestock        = mean(livestock, na.rm = TRUE)
  ) %>%
  ungroup()

# For binary shock variables: propagate max within hh-year
# (if any member experienced it, hh experienced it)
df <- df %>%
  group_by(id_hh, year) %>%
  mutate(across(
    c(sk_vl_rob_money, sk_vl_rob_product, sk_vl_rob_goods,
      sk_vl_rob_destruction, sk_vl_rob_land),
    ~max(., na.rm = TRUE)
  )) %>%
  ungroup()

# Panel D: Household-level (collapsed across all years)
df <- df %>%
  group_by(id_hh) %>%
  mutate(
    n_hh        = row_number(),
    leave_hh_t  = sum(leave, na.rm = TRUE),
    d_leave_hh_t = as.integer(leave_hh_t > 0),
    # Household-level binary: ever experienced?
    hh_d_violence         = as.integer(sum(d_violence, na.rm = TRUE) > 0),
    hh_sk_vl_rob_money    = as.integer(sum(sk_vl_rob_money, na.rm = TRUE) > 0),
    hh_sk_vl_rob_product  = as.integer(sum(sk_vl_rob_product, na.rm = TRUE) > 0),
    hh_sk_vl_rob_goods    = as.integer(sum(sk_vl_rob_goods, na.rm = TRUE) > 0),
    hh_sk_vl_rob_destruction = as.integer(sum(sk_vl_rob_destruction, na.rm = TRUE) > 0),
    hh_sk_vl_rob_land     = as.integer(sum(sk_vl_rob_land, na.rm = TRUE) > 0)
  ) %>%
  ungroup()

# Panel E: Village-year level
df <- df %>%
  group_by(reczd, year) %>%
  mutate(
    n_vill_y    = row_number(),
    v_deathwounded = mean(deathwounded_100, na.rm = TRUE),
    v_s_violence   = sum(d_violence, na.rm = TRUE),
    v_d_violence   = as.integer(v_s_violence > 0)
  ) %>%
  ungroup()

# Panel F: Village level
df <- df %>%
  group_by(reczd) %>%
  mutate(
    n_vill       = row_number(),
    v1_s_violence = sum(d_violence, na.rm = TRUE),
    v1_d_violence = as.integer(v1_s_violence > 0)
  ) %>%
  ungroup()

# ============================================================
# 8. INDEXES
# ============================================================

df <- df %>%
  mutate(
    index_agri  = sk_vl_rob_land + sk_vl_rob_product,
    index_asset = sk_vl_rob_money + sk_vl_rob_goods + sk_vl_rob_destruction
  )

# Lagged shock variables
df <- df %>%
  arrange(id_hh, year) %>%
  group_by(id_hh) %>%
  mutate(
    across(
      c(sk_vl_rob_land, sk_vl_rob_product, sk_vl_rob_money,
        sk_vl_rob_goods, sk_vl_rob_destruction, index_agri, index_asset),
      ~lag(.), .names = "lag_{.col}"
    )
  ) %>%
  ungroup()

# ============================================================
# 9. MERGE POVERTY STATUS
# ============================================================

cat("Merging poverty status...\n")
poverty_98    <- read_dta("data/origin/poverty_status98.dta")
poverty_98_07 <- read_dta("data/origin/poverty_status98-07.dta")

df <- df %>%
  left_join(poverty_98,    by = c("reczd", "numen")) %>%
  left_join(poverty_98_07, by = c("reczd", "numen"))

# ============================================================
# 10. PROVINCE TIME TREND
# ============================================================
# Stata: bys province year: gen province_trend=_n
# In R/fixest: use province[year] as interacted FE instead
# But we keep this for reference/alternative specs

df <- df %>%
  group_by(province, year) %>%
  mutate(province_trend = row_number()) %>%
  ungroup()

# ============================================================
# 11. APPLY LABELS
# ============================================================

df <- apply_labels(df)

# ============================================================
# 12. SAVE PROCESSED DATASET
# ============================================================

cat("Data preparation complete.\n")
cat(sprintf("  Total obs (all sample): %d\n", nrow(df)))
cat(sprintf("  Unique individuals: %d\n", n_distinct(df$id_person)))
cat(sprintf("  Unique households: %d\n", n_distinct(df$id_hh)))
cat(sprintf("  Years: %d to %d\n", min(df$year), max(df$year)))

# Return the processed dataframe
# (assign to environment when sourced)
df_panel <- df

# ============================================================
# BASELINE SAMPLE CREATION
# ============================================================
# This is the BASELINE sample used throughout the paper:
# - Only parental households (numsplit == 0)
# - Non-missing age
# - Registered in 1998 (Code98 not missing)
# - Non-marriage migration (restr_7 == 1)

df_baseline <- df %>%
  filter(
    numsplit == 0,
    !is.na(age),
    !is.na(Code98),
    restr_7 == 1
  ) %>%
  mutate(age = year - born_year_07)  # Recalculate age from birth year

cat(sprintf("\nBaseline sample (non-marriage, parental HH):\n"))
cat(sprintf("  Obs: %d\n", nrow(df_baseline)))
cat(sprintf("  Individuals: %d\n", n_distinct(df_baseline$id_person)))
cat(sprintf("  Households: %d\n", n_distinct(df_baseline$id_hh)))

# ============================================================
# HOUSEHOLD-YEAR LEVEL DATASET
# ============================================================

df_hh_year <- df_baseline %>%
  filter(hh == 1) %>%
  select(id_hh, year, reczd, province,
         d_leave_hh, leave_hh, d_violence, deathwounded_100,
         starts_with("sk_vl_"), starts_with("sk_nt_"), starts_with("sk_ec_"),
         starts_with("index_"), starts_with("hh_"),
         starts_with("lag_"),
         starts_with("pca_"),
         Poverty_status_98, Poverty_status_07,
         n_hh, n_vill_y, n_vill,
         v_d_violence, v_deathwounded, v1_d_violence)

cat(sprintf("\nHousehold-year sample:\n"))
cat(sprintf("  Obs: %d\n", nrow(df_hh_year)))
cat(sprintf("  Households: %d\n", n_distinct(df_hh_year$id_hh)))
