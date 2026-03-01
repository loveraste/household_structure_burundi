# ============================================================
# Civil War and Household Structure - Burundi
# Akresh, Muñoz-Mora & Verwimp (2025)
# ============================================================
# 03a: Household-Level Analysis (Table 4)
# Equivalent to: 03a_Household_Akresh-etal_July2025.do (regressions)
#
# Model: Migration_jvt = α(Victimization)_jvt + c_j + year_t + province×year + ε
# ============================================================

library(tidyverse)
library(fixest)
library(modelsummary)
library(gt)

source("code/utils/labels.R")
source("code/utils/helpers.R")

if (!exists("df_hh_year")) source("code/00_data_prep.R")
if (!exists("df_pca"))     source("code/00b_gen_pca.R")

# Merge PCA into household-year data
df_hh <- df_hh_year %>%
  left_join(df_pca %>% select(id_hh, year, pca_agri, pca_asset, pca_all),
            by = c("id_hh", "year"))

# ============================================================
# TABLE 4: Household-Level Baseline Regressions
# ============================================================
# 9 columns: 2 village-level + 5 household victimization + 2 indexes

cat("Running Table 4: Household FE regressions...\n")

# Outcome variable: at least one HH member migrates for non-marital reason
outcome <- "d_leave_hh"

# Define regressors for each column (from paper)
regressors <- list(
  "Col1_village_exposure"   = "d_violence",
  "Col2_village_intensity"  = "deathwounded_100",
  "Col3_loss_land"          = "sk_vl_rob_land",
  "Col4_theft_crops"        = "sk_vl_rob_product",
  "Col5_theft_money"        = "sk_vl_rob_money",
  "Col6_theft_goods"        = "sk_vl_rob_goods",
  "Col7_destruction_house"  = "sk_vl_rob_destruction",
  "Col8_index_agri"         = "index_agri",
  "Col9_index_asset"        = "index_asset"
)

# Run all columns
models_table4 <- lapply(regressors, function(x) {
  fml <- as.formula(paste0(outcome, " ~ ", x,
                           " | id_hh + year + province[year]"))
  feols(fml, cluster = ~reczd, data = df_hh)
})

# ============================================================
# RENDER TABLE 4
# ============================================================

coef_labels_4 <- c(
  "d_violence"           = "Violence in a given year (yes=1)",
  "deathwounded_100"     = "Number of casualties in a given year",
  "sk_vl_rob_land"       = "Loss of land (yes=1)",
  "sk_vl_rob_product"    = "Theft of crops (yes=1)",
  "sk_vl_rob_money"      = "Theft of money (yes=1)",
  "sk_vl_rob_goods"      = "Theft or destruction of goods (yes=1)",
  "sk_vl_rob_destruction" = "Destruction of house (yes=1)",
  "index_agri"           = "Index of Agricultural Related Losses (land and/or crops)",
  "index_asset"          = "Index of Asset Related Losses (money, goods, and/or house)"
)

gof_map4 <- tribble(
  ~raw,   ~clean,                    ~fmt,
  "nobs", "Observations",            0
)

table4 <- modelsummary(
  models_table4,
  coef_map  = coef_labels_4,
  gof_map   = gof_map4,
  stars     = c("*" = .10, "**" = .05, "***" = .01),
  fmt       = 3,
  statistic = "[{std.error}]",
  output    = "gt"
) %>%
  tab_header(
    title    = "Table 4. Baseline Results: Civil War and Migration, Household-level Analysis",
    subtitle = "Dependent Variable: At least one household member migrates outside household in a given year (yes=1)"
  ) %>%
  tab_spanner(
    label   = "Conflict exposure, Village level",
    columns = 2:3
  ) %>%
  tab_spanner(
    label   = "Conflict Exposure, Household level",
    columns = 4:10
  ) %>%
  tab_footnote(
    footnote = paste(
      "Robust standard errors, clustered at Sous-Colline level. * p<0.10 ** p<0.05 *** p<0.01.",
      "All specifications include Household FE, Year FE, and Province-specific time trends.",
      "Data source: 2007 Burundi Priority Panel Survey."
    )
  ) %>%
  opt_table_font(font = "Times New Roman")

# ============================================================
# ADDITIONAL HOUSEHOLD ANALYSES (by demographics)
# ============================================================

# By age group (equivalent to Appendix Table 1 in paper)
run_hh_by_group <- function(df, outcome, regressors_list) {
  lapply(regressors_list, function(x) {
    fml <- as.formula(paste0(outcome, " ~ ", x,
                             " | id_hh + year + province[year]"))
    tryCatch(
      feols(fml, cluster = ~reczd, data = df),
      error = function(e) NULL
    )
  })
}

# Adult migration (any adult leaves)
if ("any_leave_adult" %in% names(df_hh)) {
  models_adult <- run_hh_by_group(
    df_hh, "any_leave_adult",
    list(d_violence = "d_violence", deathwounded = "deathwounded_100",
         agri = "index_agri", asset = "index_asset")
  )
}

# Child migration (any child leaves)
if ("any_leave_child" %in% names(df_hh)) {
  models_child <- run_hh_by_group(
    df_hh, "any_leave_child",
    list(d_violence = "d_violence", deathwounded = "deathwounded_100",
         agri = "index_agri", asset = "index_asset")
  )
}

# ============================================================
# SAVE RESULTS
# ============================================================

models_hh_baseline <- list(table4 = models_table4)
saveRDS(models_hh_baseline, "out/models_table4_household.rds")

cat("Table 4 household regressions saved.\n")
cat("Key results:\n")
for (nm in names(models_table4)) {
  m <- models_table4[[nm]]
  b  <- coef(m)[1]
  se <- se(m)[1]
  p  <- pvalue(m)[1]
  stars <- if (p < .01) "***" else if (p < .05) "**" else if (p < .10) "*" else ""
  cat(sprintf("  %s: %.3f%s [%.3f]\n", nm, b, stars, se))
}
