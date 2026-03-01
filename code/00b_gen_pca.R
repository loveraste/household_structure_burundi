# ============================================================
# Civil War and Household Structure - Burundi
# Akresh, Muñoz-Mora & Verwimp (2025)
# ============================================================
# 00b: Generate PCA Indices
# Equivalent to: 00b_Gen_PCA.do
#
# Creates household-year level PCA indices for shock categories.
# Output: data/job/pca_r.rds (R version of pca.dta)
# ============================================================

library(haven)
library(tidyverse)
library(psych)  # for principal()

# Load data (run after 00_data_prep.R)
if (!exists("df_panel")) source("code/00_data_prep.R")

# ============================================================
# 1. PREPARE HOUSEHOLD-YEAR DATA FOR PCA
# ============================================================

# Keep one observation per household-year (household level)
df_hh <- df_panel %>%
  filter(numsplit == 0, !is.na(Code98)) %>%
  group_by(id_hh, year) %>%
  slice(1) %>%
  ungroup()

# ============================================================
# 2. PCA FUNCTIONS
# ============================================================

#' Run PCA and extract first component scores
#' @param df Data frame
#' @param vars Character vector of variables for PCA
#' @param name Output variable name
#' @return Numeric vector of first component scores
run_pca_scores <- function(df, vars, name) {
  X <- df %>% select(all_of(vars)) %>% as.matrix()
  # Remove rows with all zeros or NA
  valid <- rowSums(is.na(X)) == 0
  scores <- rep(NA_real_, nrow(X))

  if (sum(valid) > ncol(X)) {
    pca_result <- tryCatch(
      principal(X[valid, ], nfactors = 1, rotate = "none", scores = TRUE),
      error = function(e) NULL
    )
    if (!is.null(pca_result)) {
      scores[valid] <- as.numeric(pca_result$scores[, 1])
    }
  }
  scores
}

# ============================================================
# 3. COMPUTE PCA INDICES
# ============================================================

cat("Computing PCA indices...\n")

# Agricultural losses PCA: land theft + crop theft
agri_vars  <- c("sk_vl_rob_land", "sk_vl_rob_product")

# Asset losses PCA: money theft + goods destruction + house destruction
asset_vars <- c("sk_vl_rob_money", "sk_vl_rob_goods", "sk_vl_rob_destruction")

# All losses combined
all_vars   <- c(agri_vars, asset_vars)

# Economic shocks PCA
eco_vars   <- c("sk_ec_input_access", "sk_ec_input_price",
                "sk_ec_nonmarket", "sk_ec_output_price")

# Coping strategies
coping_vars <- c("sk_ec_sell_land", "sk_ec_sell_other", "sk_ec_rec_help")

# Weather shocks
weather_vars <- c("sk_nt_rain", "sk_nt_drought")

# Natural shocks (harvest/erosion)
natural_vars <- c("sk_nt_disease", "sk_nt_crop_bad", "sk_nt_destru_rain", "sk_nt_erosion")

# All natural shocks combined
natural_all_vars <- c(weather_vars, natural_vars)

# Compute PCA scores
df_hh <- df_hh %>%
  mutate(
    pca_agri        = run_pca_scores(df_hh, agri_vars,     "pca_agri"),
    pca_asset       = run_pca_scores(df_hh, asset_vars,    "pca_asset"),
    pca_all         = run_pca_scores(df_hh, all_vars,      "pca_all"),
    pca_economic    = run_pca_scores(df_hh, eco_vars,      "pca_economic"),
    pca_coping      = run_pca_scores(df_hh, coping_vars,   "pca_coping"),
    pca_weather     = run_pca_scores(df_hh, weather_vars,  "pca_weather"),
    pca_natural     = run_pca_scores(df_hh, natural_vars,  "pca_natural"),
    pca_natural_all = run_pca_scores(df_hh, natural_all_vars, "pca_natural_all")
  )

# ============================================================
# 4. HOUSEHOLD-LEVEL AGGREGATES
# ============================================================
# Mean PCA score across all years (household-level summary)

df_hh_pca_agg <- df_hh %>%
  group_by(id_hh) %>%
  summarise(
    pca_agri_hh         = mean(pca_agri, na.rm = TRUE),
    pca_asset_hh        = mean(pca_asset, na.rm = TRUE),
    pca_all_hh          = mean(pca_all, na.rm = TRUE),
    pca_economic_hh     = mean(pca_economic, na.rm = TRUE),
    pca_coping_hh       = mean(pca_coping, na.rm = TRUE),
    pca_weather_hh      = mean(pca_weather, na.rm = TRUE),
    pca_natural_hh      = mean(pca_natural, na.rm = TRUE),
    pca_natural_all_hh  = mean(pca_natural_all, na.rm = TRUE),
    .groups = "drop"
  )

# ============================================================
# 5. SAVE PCA DATA
# ============================================================

pca_out <- df_hh %>%
  select(id_hh, year,
         pca_agri, pca_asset, pca_all,
         pca_economic, pca_coping, pca_weather,
         pca_natural, pca_natural_all) %>%
  left_join(df_hh_pca_agg, by = "id_hh")

# Save as RDS for R workflow
saveRDS(pca_out, "data/job/pca_r.rds")
cat("PCA data saved to data/job/pca_r.rds\n")

# Summary of PCA outputs
cat("\nPCA Summary:\n")
pca_out %>%
  select(starts_with("pca_")) %>%
  summary() %>%
  print()

df_pca <- pca_out
